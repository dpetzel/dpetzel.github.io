---
categories: [AWS,Cassandra]
date: 2017-05-08
tags: [Cassandra,Datastax,AWS]
title: Rethinking Datastax Opscenter HA on AWS
type: post
---

Recently I've been working on building a highly available installation of Datastax Opscenter in
an automated fashion on AWS. I've decided to abandon my pursuit of installing Opscenter with automatic 
fail over and will propose an alternate solution which I believe still achieves high availability as well as
much better self-healing.

<!--more-->

**DISCLAIMER** This is not a proven solution, while I believe it should work, understand this is a proposal.

Before we get started lets define what "High Availability" or "Highly Available" means since this term is somewhat
subjective to the individual. I think this quote from https://www.digitalocean.com/community/tutorials/what-is-high-availability sums it up pretty well:

> High availability is a quality of a system or component that assures a high level of operational performance for a given period of time.

For our purposes we won't squabble over how many [Nines](https://en.wikipedia.org/wiki/High_availability#.22Nines.22) we need in order to be considered HA. We'll simply agree it means "keep downtime a minimum".

With that out of the way let me set the stage for how I got to this point. Over the last several weeks I've been
getting up to speed with the Cassandra ecosystem. The company I work for already has an established relationship
with Datastax, however we are looking to migrate a new application to Cassandra and I'll be heavily involved 
in both building and maintaining some new Cassandra clusters. Up until this project I've had virtually zero
exposure to Cassandra. As a result of this I've defaulted to trying to do things "The Datastax Way", when that
makes sense for our use cases.

Datastax has their own HA solution which they refer to as [Automatic Failover](https://docs.datastax.com/en/latest-opsc/opsc/configure/configFailover.html). Naturally I started down the path of implementing their solution as outlined, however along that path I ran into a number of rough patches which has left me believing a different approach will be better. Since my system will be deployed into AWS and not a traditional data center I have a very powerful infrastructure API at my disposal. If I were building this solution in a more traditional managed data center
it is very likely I'd adhere much closer to the Datastax provided solution.

**Disclaimer** The work I have done so far involved a decent amount of research and reviewing Datastax documentation. 
I've setup Opscenter a few times, however I have not fully deployed an automated fail over cluster (because of some 
of the issues I'll describe below). 
As a result of this I can't speak with any authority on how well their solution actually works, but I'm going to give 
them benefit of the doubt and assume it works. I'll keep this assumption in mind as I compare the merits of my proposed 
design against theirs.

I'll start by outlining the proposed design, and compare the aspects of each design in the context of the
challenges I see.

## The Alternate Design
* Opscenter will be pre-installed on a "Baked AMI".
* There will be one, and only one, instance of Opscenter (please close your jaw if it just dropped, 
  I promise this isn't as insane as it sounds and I'll explain more in a bit).
* This single instance will be under the control of an autoscale group (yep, and ASG with a min of 1, and max of 1)
* There will be a dedicated EFS (NFS) filesystem where opscenter files will be stored. A mount target will be
  exposed in each availability zone, and the instance will mount it using the zone independent DNS name
* There will be three dedicated ENIs, one in each availability zone, separate from the instance's auto-assigned one.
  Whenver a new instance is launched, it will detect its current AZ and mount the ENI that resides in the same AZ.
* There will be a Route53 DNS entries that is mapped to the active ENI
* The Datastax agents will be configured to point at this Route53 DNS entry.

This represents the minimum components required to replace Datastax's solution. 
There are certainly other "frills" you can add, but I don't consider them core to the design so I'm omitting them.
Now lets get into the meat of how things will work.

## Upgrades
Based on the steps outlined in https://docs.datastax.com/en/upgrade/doc/upgrade/opscenter/upgradeOpscFailover.html
you are ensured some amount of downtime to perform upgrades. The instructions have you shutting down the 
secondary before upgrading the primary. In this situation you've basically turned off automatic failover and 
you're down for the duration of the upgrade. To be fair, this appears to basically just be an RPM upgrade so 
it probably won't take very long.

The take away here is that the steps are manual. We can of course automate ourselves out of that situation, but 
that would require us to implement some sort of multiple machine orchestration/configuration management tool 
that would need to be programmed with a method to identify who the master is, and then down the secondary. 
Don't get me wrong I fully agree that all this *can* be automated, but it comes with a number of moving parts
 (any of which can fail). 

I believe there is a simpler upgrade path we can take. I want to be clear here that what I am about to outline
results in the overall upgrade time taking a little longer, but I believe its both safer and easier. 

In this proposed design we'd have a fresh AMI already baked with the new version of Opscenter.

The next thing we do is upgrade the ASG launch configuration to tell it launch any new instances using the new
AMI ID. Ideally you're automating this with something like cloudformation or Terraform. At this point no changes
have been made on your running Opscenter instance.

When the time is right, you then terminate the running instance (close that jaw). This is where the real magic 
of the process starts to come through. Lets step through the sequence of events:

1. The termination signal is going to gracefully shutdown our instance, ensuring Opscenter gracefully closes
   file handles. At this point the EFS volume with all your Opscenter "data" remains intact and disconnected
   from the previous instance.
1. At this point the ASG will launch a fresh instance, using the new AMI ID which has our updated version of
   Opscenter installed. For those of you who have used auto-scaling you know this won't be instant and might take
   a minute or two. Its this delay that causes this approach to be a little slower than the RPM upgrade
1. As the new instance boots up it will claim the appropriate ENI and configure itself to use it.
1. After claiming the ENI, and determining the private IP of that ENI, the instance will update the Route53 entry. 
1. Next the new instance will mount the EFS volume.
1. Finally Opscenter will be started. At this point this new instance has all the data, and the secondary IP
   associated with the ENI. Since the agents were configured with DNS entries, they should reconnect.

So what happens if an upgrade goes bad? I'll skip the troubleshooting process as that'll be similar in both
approaches. Lets assume we've gotten ourselves to a point where we need to rollback. In the traditional approach
you'd likely attempt an RPM downgrade, which will probably work, however experience tells me that RPM downgrades
are not always successful, leaving the system in odd states. In the proposed solution you would simply revert
the launch configuration back to the previous AMI and terminate the currently running instance. At that point the
steps outlined above would be executed and you'd get an older version up and running.

Let's move onto some of the challenges I found and how this alternate solution addresses them.
 
## Data/Configuration Synchronization
This section will focus on much of the material discussed in https://docs.datastax.com/en/latest-opsc/opsc/configure/enableFailover.html. The TLDR of the page is that you need to store your data/configuration on a shared file system such as NFS, or you need to sync the data between the nodes using something like rsync and cron.

Let's face it, we've all been there and done that. It gets the job but its error prone. I don't want to spend a bunch of time chasing the "what ifs" but a few need to be discussed. 

rsync will require that machine keys get exchanged. This is doable and not terribly hard with automation, but
what happens when one of the nodes eventually dies. Either you, or some automation/orchestration you've written
needs to reconfigure these jobs so the two new nodes are now talking. Doable, but in the proposed solution all
this data was stored on the NFS volume and you never had to sync anything. When nodes fail and/or are replaced you don't
need to reconfigure anything, the data is "just there". So this is one of those places where we can both simplify
things as well as raise the level of self healing the system is able to perform.

What about sharing the NFS across the instances you say? Sure, its an option, but look at those instructions and how specific some of those 
paths are. This one really made me winch a little:

> Note: The failover_configuration_directory should not be mirrored across OpsCenter installs when configuring OpsCenter to support failover

Well as it turns out `failover_configuration_directory` by default is `/var/lib/opscenter/failover/`. 
The docs having you syncing multiple things in `/var/lib/opscenter`, so at this point you can't simply 
mount/symlink that entire directory, and instead have to start cherry picking. 

What happens if a future update adds another file to that directory that you need and you missed it in the 
release/upgrade notes. Don't get me wrong, you can make this work, its just unnecessarily error prone.

I can already here someone saying "just relocate `failover_configuration_directory`". That would certainly
make the sync configuration a little simpler, but now you've deviated away from "factory defaults" which can
come with its own challenges down the road.

So I'll wrap up this section by simply re-iterating that yes I'm confident we can make it work, but I also
think we can just make it simpler by keeping all that stuff on the EFS volume, which is only mounted by a single instance, and avoiding syncing/sharing.

## Network Splits
Let's face it, sh*t happens in the network and splits (or partitions) happen. If your following Cassandra best
practices for AWS you're likely splitting your nodes across multiple availability zones (probably 3). 
Its not a matter of if, its a matter of when, a partition will happen. 
Lets look at what DataStax has to say on the matter:

> Note: If a failover occurred due to a network split, the formerly primary OpsCenter must be manually shut down, and another backup configured when network connectivity has been restored. Upon startup, each OpsCenter instance generates a unique id (uuid), which is stored in the failover_id file. In the event of a network split, a failover_id uniquely identifies each OpsCenter to agents and prevents both OpsCenter machines from running operations post-failover, which could corrupt data. The location of failover_id file depends on the type of install and is configurable.

This part is especially troubling to me:

> must be manually shut down, and another backup configured when network connectivity has been restored

This whole process feels brittle and error prone to recover from. If we only run a single instance we avoid this
whole situation. There can't be any split brain when there is only one brain :)

This does however warrant some thought on the impact of availability in the event that one or more zones are lost.
Since OpsCenter clusters can only be 2 nodes, a failure of 2 zones (assuming its the two that Opscenter instances are in) will be just as impactful, so the real difference comes down to a single zone failure.

The specifics of how this play out could vary wildly depending on the nature of the failure, but if we are
assuming the zone is "gone", then the ASG (which is configured to span multiple zones) should launch a new
instance into a functional zone. I fully admit, I've never seen a zone "go way" so this is more theory than
practice.

## Agent Reconfiguration
This section has some overlap with the previous section but is more general in nature. Datastax says the
following about fail over events:

> The backup OpsCenter automatically reconfigures the agents by automatically changing stomp_interface in address.yaml to connect to the backup instance instead of the failing primary instance.

> Ensure that address.yaml is not being managed by third-party Configuration Management. During failover, OpsCenter automatically changes stomp_interface in address.yaml to point to the backup opscenterd instance. If a separate Configuration Management system is managing address.yaml, that change might be undone when the Configuration Management system pushes its next update.

To me this feels brittle. When everything is firing perfectly this might work well, but what happens in the
case of the network split above? Its a little unclear to me how this works. If it fires that change only once
what happens if some number of nodes can't be reached? 

Thinking about the network split situation above, it would seem some number of nodes wouldn't be managed 
for a period of time. It just feels like there are lot of moving parts happening here, any of which could
go wrong in unexpected ways.

Remember that Route53 entry we talked about before? That eliminates the need for ever changing the configuration on the
agents, since it will simply "move" to the appropriate instance. If your one of those shops who like to 
manage *all* your configuration files with your configuration management solution you can do that now 
without the fear of the situation quoted above. 

## Lock In
There are two quotes from https://docs.datastax.com/en/latest-opsc/opsc/configure/configFailover.html I want to
address in this section.

> If the newly configured backup OpsCenter detects any DataStax Community or open source Cassandra clusters, it logs an entry and shuts itself down.

> Note: If a non-DataStax Enterprise cluster is added after enabling automatic failover, OpsCenter fires an alert that automatic failover will not work and the backup OpsCenter instance shuts down.

While I don't currently have any plans to run community edition or open source Cassandra, having that option
taken out of my hands is unsettling. Its not unreasonable to think we might leverage one of those other solutions
for some of our less critical applications/workloads. 

They make is sound like having a single OpsCenter will allow you to manage these other editions. If that is case
the alternate solution of a single node keeps our options open.

## Costs
I should note that the cost of running Opscenter will likely be a drop in the bucket compared to the costs of 
running the Cassandra cluster(s), however we should be aware of the cost ramifications of our decisions.

There are a few cost considerations, and I fully admit all of them are probably pocket change compared to
your monthly AWS spend but I think its important to understand them.

The first cost we need to consider is the cross zone traffic charges. A lot of people don't know this but AWS
does charge you for network traffic that crosses availability zones: https://aws.amazon.com/ec2/pricing/on-demand/
Look at the section titled "Data Transfer OUT From Amazon EC2 To" and you'll see this entry

> Amazon EC2, Amazon RDS, Amazon Redshift or Amazon ElastiCache instances, Amazon Elastic Load Balancing, or Elastic Network Interfaces in another Availability Zone or peered VPC in the same AWS Region

I've omitted the actual cost as it may change by the time you read this, but the take away is that cross zone
traffic isn't free, and there are a couple sources of cross zone traffic.

The largest source (I suspect) will be the agents on each Cassandra node communicating with Opscenter (and vice versa). 
This cost will actually be the same in both configurations. Since OpsCenter is active passive two thirds of
your agents will be crossing zones. That will be exactly the same in the proposed solution.

The next source of cross zone traffic will be the heart beats between the primary and backup. In the proposed
solution we do away with this charge since there is no backup to exchange information with. In additions to the
heartbeats, if we were using the rsync solution, we'd be paying for that well. To be clear, this data volume
is so small, the charge will probably be extremely low.

The more obvious cost savings is the actual EC2 instance that we get to avoid running. We are basically cutting
our compute charges in half by only running a single instance.


## Conclusion
If you've made it this far I applaud and thank you! As I stated earlier if your still in a traditional data
center I think the Datastax solution is a very solid option, but if your lucky enough to be running in a cloud
where you've got access to infrastructure APIs there are other options.

As is the case with any solution there are pros and cons. This solution is no different, but for me the pros 
have the potential to outweigh the cons and I look forward to giving it a test drive in the real world.


