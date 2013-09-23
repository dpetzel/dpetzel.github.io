BIG-IP LTM VE on VirtualBox
===========================



.. author:: default
.. categories:: VirtualBox
.. tags:: F5, BigIP, VirtualBox
.. comments::

I wanted to do some testing on a Zenoss BIG-IP ZenPack I wrote today, and I didn't have the access to a test box that I had when I initially wrote it. So I decided I'd give the BIG-IP LTM VE a whirl.

.. more::

I'm on a VirtualBox kick right now, but the appliance choices there don't list VirtualBox. Inspired by this post, I figured I'd give it a shot since it looked simple enough. I'm re-documenting the process here, so I can just add a little more detail around this.

Start by registering (or signing in if you already have an account) via https://www.f5.com/trial/big-ip-ltm-virtual-edition.php.

Navigate the screens to get your trial key, and subsequent download. You'll want to grab the ESXi based ova file MAKE SURE YOU DOWNLOAD THE 10.1 OVA. I thought I would be cool and download the 10.2 file. Turns out you can’t activate the 10.2 trial… How dumb… anyway save yourself some time and just download 10.1

From within the VirtualBox UI, select File --> Import Appliance

Select Choose and locate the .ova file you just downloaded. Click Next

There are just a couple of settings you'll want to tweak on Import Settings page:

#. Give your appliance a name (or just accept the default)
#. Change to 2 CPUs
#. Changes to 2048MB of RAM
#. Change the file extension on the virtual disk image to be a .vdi

You should see a license agreement, agree to it of course.

One the import is complete, I’d suggest setting each network adaptor to host-only networking, unless you really need it to talk externally. Regardless of if you change that or not, power on the VM now.

The first thing you’ll need to do is assign a management IP. Start by logging into the vm through the VirtualBox console. credentials are root/default. At the CLI type config. I opted let DHCP do its thing by answering Yes “use automatic configuration of ip address”

type ifconfig and you should see any entry like eth0:mgmt. This will give you the IP address of your management interface. Using https navigate to that IP addresses in a browser on your workstation. https://192.168.1.100 (or whatever IP you got). **NOTE** the username and password for the UI is different than the cli. Use admin/admin for logging into the webui

You’ll be prompted to run through a setup wizard. Its self explanatory enough that I don’t think I need to cover it here. From here you are on your own. Proceed as you see fit.
