---
title: Remotely Enabling RDP
layout: post
categories:
  - Tips/Windows
tags: [windows, rdp]
date: 2014-04-30
---

Nothing to exciting here, but its the 3rd or 4th time in recent history I've
had to go looking for this, so I figured I would write it down finally.

There are times when a domain attached PC has RDP disabled for some reason.
The following snippet, which I adapted from
<http://oreilly.com/windows/archive/server-hacks-remote-desktop.html> makes it a
little quicker. Run this from a cmd prompt as a user with admin rights on the
remote host.

{% highlight bat %}
set node=remote_pc_name
sc \\%node% start RemoteRegistry
reg add "\\%node%\HKLM\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /d 0 /f
{% endhighlight %}
