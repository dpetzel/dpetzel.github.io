---
layout: post
title: "Migrating from Windows 2003 SBS to Windows 2012 Standard Part I"
category: "System Administration"
tags: [windows, small business server, active directory]
---
{% include JB/setup %}
I've recently been tasked with migrating a Windows 2003 Small Business Server
to Windows 2013 Standard.

Without getting into too much of the back story, the client purchased Windows
2003 SBS many moons ago, however they never leveraged anything except Active
Directory and File Sharing. They use their hosting provider's web mail, and
don't have an appetite to change that.

Here are we many moons later and they are ready to upgrade. They've purchased a
new, fairly beefy, box running Windows 2012 Standard.

After some discussions around the path they would prefer to take we've decided
we don't want to have to touch all of the PCs and move them to a new domain,
and we'd like the upgrade to be as seamless as possible. To that end the decision
was made to attempt a *migration*. This document will hopefully capture my
journey down this path. Its been at least 5 years since I've touched a "real"
domain controller, so a decent amount of reading is order, but from what I have
gathered so far this is not a standard conversion path, but it appears there
are some options.

## Getting Prepared
So I decided I'd blow away the existing installation of 2012 on the box and
lay down ESXi. I then re-installed 2012 fresh as a VM on the ESXi host. I also
performed a P2V on the existing Windows 2003 SBS host. The P2V process is
outside the scope of this document, but was actually pretty easy. This will
allow me to take snapshots, and even clone the VM for some trial runs
(I don't have any lab hardware available for this).

fter getting the SBS server virtualized, I proceed to configure the new 2013 box as a member server with a static IP. I ensured its primary DNS server was set to the SBS server. I did not configure any roles or features at all yet.


Now that I'm ready to proceed, I started by installing the support tools
from <http://www.microsoft.com/en-us/download/details.aspx?id=15326>. With those
tools in place I ran through series of tests as outlined in <http://msmvps.com/blogs/mweber/archive/2012/07/30/upgrading-an-active-directory-domain-from-windows-server-2003-or-windows-server-2003-r2-to-windows-server-2012.aspx>

{% highlight console %}  
Dcdiag /v /c /d /e /s:<sbs_server> > c:\temp\dcdiag.log
{% endhighlight %}

The first error logged was:
{% highlight console %}
    * Checking Service: IsmServ
        IsmServ Service is stopped on [SERVER]
    ........................ SERVER failed test Services
 {% endhighlight %}

Based <http://blog.mpecsinc.ca/2008/07/sbs-dcdiag-produces-ismserv-error.html>,
it appears this is expected on SBS and safe to ignore, so doing just that.

The next error up was:

{% highlight console %}
      Starting test: systemlog
         * The System Event log test
         An Error Event occured.  EventID: 0xC0002719
            Time Generated: 11/28/2013   18:05:14
            (Event String could not be retrieved)
         ......................... SERVER failed test systemlog
{% endhighlight %}

This seems to be related to a single event in my event log:
```console
	Event Type:	Error
	Event Source:	DCOM
	Event Category:	None
	Event ID:	10009
	Date:		11/28/2013
	Time:		6:05:14 PM
	User:		N/A
	Computer:	SERVER
	Description:
	DCOM was unable to communicate with the computer sbs.ip.add.ress using any of the configured protocols.

	For more information, see Help and Support Center at http://go.microsoft.com/fwlink/events.asp.
```
I don't see any other occurrences of this error. I'm assuming I could clear the
event logs to not see, but I'd rather keep the event log history around, so I'm
going to ignore this for now.

All the other tests passed, so I moved onto `Repadmin`:

```console
Repadmin /showrepl sbs_host /verbose /all /intersite >c:\repl.log
```

Nothing jumped out at me in this output. Next up `dnslint`
```console
  Dnslint /v /ad /s "DCipaddress"
```

This one caught something interesting:

```console
Notes:
One or more DNS servers is not authoritative for the domain
```

After reviewing the output I found that at some point in time someone had
created a local host file entry for localhost that was the IP of the server.
Traditionally I believe localhost resolves to 127.0.0.1, rather than the actual
box IP, so I simply commented out the file entry. After that `dnslint` came
back clean.

I skipped the `adreplstatus` checks since this is a single node, and the tool
wanted me to install .net framework 4.0, which seemed heavy handed for a test
I didn't care about.

Next up I confirmed that both the `_msdcs.domain.local` and `domain.local` zones
were set to the `Active Directory-Integrated` type.

Next, I confirmed what level AD was currently at:

```batch
Dsquery * cn=schema,cn=configuration,dc=domain,dc=local -scope base -attr objectVersion
```

This returned a value of `30` for me, which based on the link above means I'm
at the `Windows Server 2003` which lines up with the version of SBS on the host.

At this point I took a snapshot of the host as we are going to start making
changes soon.

## Upgrading
### Add 2012 Server As New Domain Controller
In my case the SBS server was at the `Windows 2000` level for **both** the
Domain Functional Level, as well as the Forest Functional Level.
Using `Active Directory Domains and Trusts` I increased both of these to the
`Windows 2003` level. This was done on the SBS 2003 node. Since its a single
SBS box, I figure replication time is essentially 0 so after trolling the Event
Logs for a few minutes to ensure nothing weird popped up, I proceeded.

I then stepped through the process of promoting the 2012 as a domain controller
which is well illustrated at  <http://blogs.technet.com/b/canitpro/archive/2013/05/05/step-by-step-adding-a-windows-server-2012-domain-controller-to-an-existing-windows-2003-network.aspx>

After the restart I noticed a few things that seemed off at first. The first
one was that I didn't have a netlogon share on the new 2012 DC. Additionally
there were some errors in the event log. I found that the
`File Replication Service` was stopped. It was set to automatic, so I started
it. After starting that service, I now had the netlogon share as well.

### Update DNS Clients
At this point I updated the DNS settings on thew new 2012 server to reference
itself first.

Once that was completed, I then update my DHCP configuration on the SBS 2003
box (I'll move DHCP later), I updated the options to pass the new box as the
primary DNS server.

### Transferring FSMO Roles
I then followed <http://blogs.technet.com/b/canitpro/archive/2013/05/27/step-by-step-active-directory-migration-from-windows-server-2003-to-windows-server-2012.aspx>
to transfer all the FSMO and related roles over to the new server.

### Update Time Configurations
As touched on toward the end of the <http://msmvps.com/blogs/mweber/archive/2012/07/30/upgrading-an-active-directory-domain-from-windows-server-2003-or-windows-server-2003-r2-to-windows-server-2012.aspx> I updated time settings as follows

2012 Server:

```batch
w32tm /config /manualpeerlist:time.windows.com /syncfromflags:manual /reliable:yes /update
```

SBS 2003 Server:

```batch
w32tm /config /syncfromflags:domhier /reliable:no /update
```
At this point I'm going to let things bake for a bit. I've got all the "AD Stuff"
moved over. At this point I'm left with all the file shares and applications
(IE Virus Console) that are configured to point at this host.  As I get to
moving some of these items I'll add new parts.

## References
* <http://social.technet.microsoft.com/Forums/windowsserver/en-US/3f0062c8-80b1-4322-8a15-6529289fcc4b/migrate-ad-from-2003-to-2012>
* <http://msmvps.com/blogs/mweber/archive/2012/07/30/upgrading-an-active-directory-domain-from-windows-server-2003-or-windows-server-2003-r2-to-windows-server-2012.aspx>
* <http://blogs.technet.com/b/canitpro/archive/2013/05/05/step-by-step-adding-a-windows-server-2012-domain-controller-to-an-existing-windows-2003-network.aspx>
* <http://blogs.technet.com/b/canitpro/archive/2013/05/27/step-by-step-active-directory-migration-from-windows-server-2003-to-windows-server-2012.aspx>
