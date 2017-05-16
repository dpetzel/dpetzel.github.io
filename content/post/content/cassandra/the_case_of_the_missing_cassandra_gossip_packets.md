---
categories: [Cassandra]
date: 2017-05-15T20:02:38-04:00
draft: false
tags: [cassandra,gossip]
title: The Case Of The Missing Cassandra Gossip Packets
type: post
---
One of my recent tasks was to automate the creation of multi-region Cassandra 
clusters. I'm still pretty green with Cassandra but have been having some recent
success with creating multi-dc (replication group) clusters inside of a single
AWS region. The story that follows summarizes what was a painful few days
of debugging....

<!--more-->


## The Journey

This story will take us all over the troubleshooting world from log files, to
AWS security groups, and finally concluding with some tcpdump action.

I'll start by trying to set the stage a little:

* I've got an existing cluster already running in one AWS region. This cluster
  is configured with multiple "data centers" aka replication groups, inside
  this cluster. Each data center spans multiple available zones for redundancy
  purposes
* The regions are currently connected with an IPSec VPN tunnel, and all nodes
  are configured to communicate over private IPs. I am not using the commonly
  referenced design of having our Cassandra nodes communicate over public IP
  addresses.
* In this specific example I'm testing Datastax Enterprise 5.1.0

The key components of what follows looks like this:
```
======= Region 1 =====            ===== Region 2 ======
node1 <==> VPN Term <== Internet ==> VPN Term <==> node2
```

As it turns out Datastax has some documentation for this exact situation located
at http://docs.datastax.com/en/dse/5.1/dse-admin/datastax_enterprise/operations/opsAddDCToCluster.html.
Its always nice to see you're not blazing any new trails.

After going through the steps in the document I got up to step #7 and things
went severely downhill from there. I was finding that sometimes my nodes
were joining up, but most times they were not. Remember I'm iterating on the 
process many times as my true goal is automating this, not simply getting it
working one time.

The one constant I did find was that every time it failed I saw the following
exception in `/var/log/cassandra/system.log`

```
ERROR [main] 2017-05-15 15:02:34,654  CassandraDaemon.java:705 - Exception encountered during startup
java.lang.RuntimeException: Unable to gossip with any seeds
        at org.apache.cassandra.gms.Gossiper.doShadowRound(Gossiper.java:1413) ~[cassandra-all-3.10.0.1652.jar:3.10.0.1652]
        at org.apache.cassandra.service.StorageService.checkForEndpointCollision(StorageService.java:555) ~[cassandra-all-3.10.0.1652.jar:3.10.0.1652]
        at org.apache.cassandra.service.StorageService.prepareToJoin(StorageService.java:810) ~[cassandra-all-3.10.0.1652.jar:3.10.0.1652]
        at org.apache.cassandra.service.StorageService.initServer(StorageService.java:671) ~[cassandra-all-3.10.0.1652.jar:3.10.0.1652]
        at org.apache.cassandra.service.StorageService.initServer(StorageService.java:617) ~[cassandra-all-3.10.0.1652.jar:3.10.0.1652]
        at org.apache.cassandra.service.CassandraDaemon.setup(CassandraDaemon.java:393) ~[cassandra-all-3.10.0.1652.jar:3.10.0.1652]
        at com.datastax.bdp.server.DseDaemon.setup(DseDaemon.java:471) ~[dse-core-5.1.0.jar:5.1.0]
        at org.apache.cassandra.service.CassandraDaemon.activate(CassandraDaemon.java:599) ~[cassandra-all-3.10.0.1652.jar:3.10.0.1652]
        at com.datastax.bdp.DseModule.main(DseModule.java:93) [dse-core-5.1.0.jar:5.1.0]

```

Live everyone does I turned to Google. There are no shortage of results for this
error message, but no resounding solution. Most threads point at firewall and/or
connectivity issues on the Gossip port (TCP 7000).

Using `tcpdump` on both Cassandra nodes I confirmed that communications were in
fact flowing between both nodes on port 7000. The logging around this error
is completely unhelpful so my next trick is to increase the logging on both
nodes. I started by changing all the `INFO` logging statements to trace:
```
sed -ie 's/INFO/TRACE/g' /etc/dse/cassandra/logback.xml
service dse restart
```

This did increase the amount of logging, but still not enough. So I added a more
specific configuration entry to the file:
```
<logger name="org.apache.cassandra" level="TRACE"/>
```
I added this right about the closing configuration element (`</configuration>`)

Now I was getting some pretty useful entries, but all they really did was confirm
what I already knew, which was that gossip messages were not working properly.

I did however expose what some of the classes involved were so I spent some time
sifting through the [Cassandra source code](https://github.com/apache/cassandra).
While educational, I didn't find any smoking guns here either. The key concept
I personally took away from this is that while it uses TCP, the gossiping is
"firing and forgetting" model so the sending of the digest isn't directly 
associated with an ACK. By that I mean a digest can be set and never get an ACK
but the internals of the communications don't seem to care. Its actually felt
more like a UDP flow...

At this point I was suspicious that maybe the latency between regions was too
high and while communications were happening they were not happening fast enough.
This turned out to be a totally bogus theory, but it did land me on https://wiki.apache.org/cassandra/ArchitectureGossip
 which is where things started heading in the right direction (although I didn't
know it yet).

After reading up on this page, specifically the section on `GossipDigestAckMessage`
I figured it was time to dive back into the packet captures, this time in more
depth. I had previously just monitored the summary of info that tcpdump spits
out on the command. This time I'd actually log them to a file and review them
in Wireshark.

It's here that my first break through happened. I saw what appeared to be the
payload of the digest ACK get sent from region 1, but it never showed up in 
region 2. Other messages were however getting there....

At this point I fired up a packet capture on all 4 boxes (Cassandra and VPN).
I could see the digest ACK leave the Cassandra node in region 1, and see it
show up on the VPN box in region 1. However, it doesn't show up on the VPN
node in region 2, but still other packets were.

So I started going through the pcap from the VPN box in region 1 with a fine
tooth comb, and then I find it... Right after the packet that appears to
be my payload, the VPN box sends an ICMP packet back to the Cassandra node.
I had over looked this earlier as I was focused on TCP port 7000.

The ICMP packet in question was a Type 3 (Destination unreachable), with Code 4
(Fragmentation needed). For those that deal with networking every day they
probably would have known what to do right away, but this was new to me so more
Googling. 

I noticed that all the packets that were getting through were all under 1K, however
this payload message was about 37K. Additionally these packets all the `DF` bit
set which says "Don't Fragment this packet".

So I tried to figure out how to turn this flag off. I know enough to understand
that fragmentation is normal part of getting data across a network. I looked
at various OS and JVM configurations, none of which were the answer.

So I started looking at MTU settings and I found the AMIs I were using, had an
MTY size of 9001 on eth0. Based on some Internet results for working with the 
DF bit I opted to reduce the MTU size via `ifconfig eth0 mtu 1422`.

From there it was like magic, nodes starting gossiping and all the nodes came
online.

Now, as we all know, a single success can't be trusted so I tore everything down,
added a line in my userdata script to set this MTU and rebuilt the cluster 
again. I actually did this 3 more times, all of which were successful.


## The Solution
For those that don't care to read about the journey above the fix for me was to
run `ifconfig eth0 mtu 1422` on all of my seed nodes that were participating
in WAN gossiping across my VPN connection


## References

* http://docs.datastax.com/en/dse/5.1/dse-admin/datastax_enterprise/operations/opsAddDCToCluster.html
* https://github.com/apache/cassandra
* https://wiki.apache.org/cassandra/ArchitectureGossip
