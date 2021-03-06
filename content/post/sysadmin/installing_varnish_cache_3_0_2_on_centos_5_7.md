---
categories: [Caching]
date: 2012-03-05
draft: false
tags: [Varnish, HTTP, Caching]
title: Installing Varnish Cache 3.0.2 on Centos 5.7
type: post
---
If you are here, you probably already know what Varnish is, but in case you don’t….https://www.varnish-cache.org/

> Varnish Cache is an open source, state of the art web application accelerator.
  It is installed in front of your webserver where it will cache the content,
  resulting in a huge performance boost.
<!--more-->

Now that we’ve gotten that out of way, lets get to it. As is the case with most
things I post, this is not intended to be an official “how-to” document, but
rather a journal of my adventures in doing it. As should always be the case
I’m starting with the supplied installation documentation located here:
https://www.varnish-cache.org/docs/3.0/installation/install.html#centos-redhat

Start with a vanilla minimal install of Centos 5.7. I did perform a `yum update`
& `reboot` after the initial installation of the OS, before starting with
installing Varnish.

Lets create a repo file and leverage Varnish’s existing repo. We also need
libedit out of EPEL, so enabling that repo as well. I suppose I could have just
grabbed the single RPM just as easily…

```shell
cd /tmp
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -i epel-release-5-4.noarch.rpm
rpm --nosignature -i http://repo.varnish-cache.org/redhat/varnish-3.0/el5/noarch/varnish-release-3.0-1.noarch.rpm
```

Install Varnish and its various dependencies

```shell
yum -y install varnish
```

Fire it up!

```shell
service varnish start
```

Check that its alive (The 503 response code is expected right now)
```shell
# curl -I http://localhost:6081
HTTP/1.1 503 Service Unavailable
Server: Varnish
Content-Type: text/html; charset=utf-8
Retry-After: 5
Content-Length: 419
Accept-Ranges: bytes
Date: Thu, 01 Dec 2011 02:27:30 GMT
X-Varnish: 1562514354
Age: 0
Via: 1.1 varnish
Connection: close
```

That’s about it, doesn’t get much easier than that. Perhaps if I get more
ambitious I’ll post some configuration tweaks and or cool tricks
(if I learn any).
