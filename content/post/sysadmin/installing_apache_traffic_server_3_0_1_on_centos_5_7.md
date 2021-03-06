---
categories: [Caching]
date: 2012-03-05
draft: false
tags: [Apache Traffic Server, HTTP, Caching]
title: Installing Apache Traffic Server 3.0.1 on Centos 5.7
type: post
---
A quick chronicle of my journey to install Apache Traffic Servers on
Centos 5.7. In the end it ended up being a lot easier than I was expecting,
given how sporadic and incomplete the documentation on their site is.
<!--more-->

Start with a vanilla minimal install of Centos 5.7. I did perform a
`yum update` & `reboot` after the initial installation of the OS, before
starting with installing ATS

Do the installation:
```shell
cd /tmp
wget http://www.carfab.com/apachesoftware//trafficserver/trafficserver-3.0.1.tar.bz2
yum -y install gcc gcc-c++ pcre pcre-devel tcl tcl-devel openssl-devel expat-devel
tar -jxvf trafficserver-3.0.1.tar.bz2
cd /tmp/trafficserver-3.0.1
./configure --prefix=/opt/trafficserver
make
make install
```

At this point it was installed for me, however I ran into one *really*
boneheaded mistake. Mostly my own fault, but the documentation in the getting
started guide is misleading as well. From this page
http://trafficserver.apache.org/docs/v2/admin/getstart.htm it says:

> #. Log on to the Traffic Server node as the Traffic Server administrator and navigate to the Traffic Server bin directory.
>
> #. Enter the following command:
>
> ./start_traffic_server
>
> ./trafficserver start

The problem is that start_traffic_server does not exist. Since I’m brand new to
traffic server, I can’t be sure, but I suspect this is a relic from 2.x. The
next challenge was running “./trafficserver start”. This gives the illusion
that the server has started, but I ran into issues with traffic_line and
traffic_shell errors. You can see the details of those errors in my
[semi-embarrassing forum post]( http://mail-archives.apache.org/mod_mbox/trafficserver-users/201111.mbox/browser):

For those that want to cut to the chase, start traffic server with
`trafficserver start` notice the omission of the underscore. Running this
command also starts traffic_cop and traffic_manager. I ended up finding this by
reading the INSTALL file that was included in the source download. Yes, I did
read the file before attempting to install, but as I already admitted, glossed
right over the closely named file.
