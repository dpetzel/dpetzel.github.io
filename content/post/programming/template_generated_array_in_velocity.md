---
categories: [Programming]
date: 2012-03-05
draft: false
tags: [Velocity]
title: Template Generated Array in Velocity
type: post
---
Today I was trying to do something in a velocity template that I found to be a little
harder than I would have guessed. I was trying to manually generate an array from within my template.
I had a single template that I needed to wrap some super crude IP checking around. I have a couple of
ip addresses which are allowed to see the template code, but everyone else should get the boot.
<!--more-->

Now, I don't write a lot of code, let alone Velocity code, so I figured I'd hit up the
user documentation for Velocity: http://velocity.apache.org/engine/devel/user-guide.htm.
Would you believe I found nothing of the sorts? I found how to loop through an existing array,
but nothing on creating a new one from within the template.

Well, after some Googling I found a few newsgroup posts. I wanted to capture the syntax here,
as it was incredibly easy. And just as if you had been provided the array from underlying Java code
you can loop through your template generated array.

```java
#set($AllowedIPs= ["1.1.1.1","2.2.2.2"])
```

Thats it. I couldn't believe it took me more than 30 seconds to find this :(. In any event
if anyone is curious the code looks a bit like the following.

*Note:* The system on which the code is running, provides access to a variable (`$remoteIPAddress`)
which is the client IP. Without that provided variable this will of course not work:

```java
#set($AllowedIPs= ["1.1.1.1","2.2.2.2"])
#foreach($IpAddress in $AllowedIPs)
   #if($remoteIPAddress eq $IpAddress)
      ## Do Whatever you need in here, and it will only happen
      ## For authorized IP addresses
   #end
#end
```
