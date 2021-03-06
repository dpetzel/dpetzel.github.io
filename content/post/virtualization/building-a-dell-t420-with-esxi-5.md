---
layout: post
title: "Building a Dell T420 with ESXi 5"
categories:
  - System Administration
tags: [Dell, VMware, ESX, OMSA, Open Manage]
date: 2013-11-24
---

I recently got the opportunity to play with a new Dell T420, and I decided I
would run ESXi 5 on it.

## Background
My day job does not really allow me much hands on access to hardware any more
so its been a while since I've gotten to build a new server, but I recently got
the chance to work on this as a side project. The server came
pre-installed with Windows 2012 Standard. I have a need to run a couple of VM's and I
decided I wanted to run ESXi on the host, and run the 2013 standard box as
a VM. For anyone that is curious, I didn't pick ESXi because its "better" than
Hyper-V (I have no clue how they stack up anymore). I simply chose it because
its been a couple of years since I've built an ESX host and I wanted to see
how things have evolved.

The first thing I did was use the VMWare converter utility to P2V the existing
installation out to a VMWare workstation format. I didn't *really* need to do
this since the OS was not customized yet, and I could reinstall, but this
was a chance to play with the converter, and see if if I could PBV the existing
installation and have it running on the newly rebuilt box. It worked well,
and maybe I'll write about that experience some day, but for now its all
about getting the box built.

## Installing Open Manage Server Administrator
So step one was to grab the installation bits from
[Open Manage Download][Open Manage Download].
I went with version 7.3.0.2 as it was the most recent available. It downloaded
the file to my workstation, as opposed to directly on the ESX host.

Next I started following the ESXi specific instructions in the
[Open Manage User Guide][Open Manage User Guide].
While I can appreciate the time it takes to work up instructions that cover such
a wide array of platforms, I found these instructions a bit lacking. They had
several typos (missing spaces in command line commands) as well as were unclear
on a couple things, so I'll spend a little more time to add some details here.

I chose to go with the "Using The vSphere CLI" portion of the instructions, as
it seemed to be the most straight forward for folks without existing ESX
infrastructures in place. So with that, I had to download and install the
[vSphere CLI][vSphere CLI]. This was pretty quick and painless. I didn't poke to much
at it, but it feels like its nothing more than a set of Perl scripts and it
adds a shortcut to a CMD session which I presume just tweaks the shell with
some environment variables

Now I copied the file over the suggested directory per the docs (I had to enable
 and start SSH access using the vSphere Client before this would work).

```batch
   pscp OM-SrvAdmin-Dell-Web-7.3.0-588_A00.VIB-ESX51i.zip root@192.168.1.1:/var/log/vmware/
   Using keyboard-interactive authentication.
   Password:
   OM-SrvAdmin-Dell-Web-7.3. | 6490 kB | 1622.6 kB/s | ETA: 00:00:00 | 100%
```

So I'm not sure how the docs assume you to unzip this, but I did it over an SSH
session, and the part that I messed up on first was that I unzipped the file
directly in `/var/log/vmware/`, when in reality all you have to do is run the
install command against the ZIP directly. There is no need to actually unzip it.

I later learned about the [vSphere Management Assistant][vSphere Management Assistant],
which I think is geared toward keeping SSH out of the mix. for now I ran the
command using the CLI

```console
   esxcli --server 192.168.1.1 software vib install -d /var/log/vmware/OM-SrvAdmin-Dell-Web-7.3.0-588_A00.VIB-ESX51i.zip

   Installation Result
      Message: The update completed successfully, but the system needs to be rebooted for the changes to be effective.
      Reboot Required: true
      VIBs Installed: Dell_bootbank_OpenManage_7.3.0.2-0000
      VIBs Removed:
      VIBs Skipped:
```

And then comes a reboot. Following the reboot I expected I would be able
to hit the OMSA HTTPS interface at https://192.168.1.1:1311, however that didn't
work, and it turns out is more more involved, and covered in the "Accessing Server Administrator on VMware ESXi"
section. Essentially it suggests that you have to a **completely separate**,
server running the web server. In my case, this is the only box on the network
so this seems like a crappy solution, but I suppose the logic is possibly to
keep the number of system daemons to an absolute minimum. In any event, I was
a bit disappointed to lose the web UI I've grown to know.

## vSphere Management Assistant
At this point, I was a bit annoyed that I needed another system.
While trolling for ways to potentially hack the Web server in directly, I came
across a YouTube video on the subject at http://www.youtube.com/watch?v=hywERi8bc1c.
While watching this at about 1:31 they jump to a screen I was not familiar with,
and after a little digging I discovered the
[vSphere Management Assistant][vSphere Management Assistant],
so I proceeded to download and *install* the virtual appliance as it seems it
will come in handy in the future as well.

So I downloaded the appliance, unzipped the file and and then followed the
instructions at http://pubs.vmware.com/vsphere-55/index.jsp#com.vmware.vma.doc/vima_get_start.4.5.html.
This all went really smooth.

## Installing Dell OMSA into the vSphere Management Assistant
So I figured what the heck, at this point I have a VM already, lets install
the OMSA web interface here since I couldn't do it earlier. So I downloaded
the file from the dell website (they make it harder than is should be to get a
direct download link that I could wget from inside the VM so instead I
downloaded it on my workstation and uploaded it.

```batch
pscp OM-SrvAdmin-Dell-Web-LX-7.3.0-350_A00.SLES11.x86_64.tar.gz vi-admin@192.168.1.2:/tmp
```

Then via an SSH into the VMA appliance:

```console
   cd /tmp
   tar -zxvf OM-SrvAdmin-Dell-Web-LX-7.3.0-350_A00.SLES11.x86_64.tar.gz
   sudo ./setup.sh
```

Accept the license agreement, and hit option 1 to install the Server Administrator Web Server Interface.
Followed by pressing "i"

And about 2 minutes later, we have our good old friend, the Open Manager web
interface available at https//vmaappliance_ip:1311, and I was able to use
it to connect to my ESXi host. A bit of a round about where to get there, but
something is better than nothing..

[Open Manage User Guide]: ftp://ftp.dell.com/Manuals/all-products/esuprt_software/esuprt_ent_sys_mgmt/esuprt_ent_sys_mgmt_opnmng_sw/dell-opnmang-sw-v7.3_User%27s%20Guide2_en-us.pdf
[Open Manage Download]: http://www.dell.com/support/drivers/us/en/19/DriverDetails/Product/poweredge-r710?driverId=WHYNF&fileId=3006491785
[vSphere CLI]: http://www.vmware.com/support/developer/vcli/
[vSphere Management Assistant]: http://www.vmware.com/support/developer/vima/
