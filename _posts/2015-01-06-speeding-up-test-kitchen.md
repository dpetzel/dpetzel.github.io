---
layout: post
title: "Speeding Up Test Kitchen"
category: Chef
tags: [testing, chef, test-kitchen]
---
{% include JB/setup %}
This past week I was turned on to a tiny, but game changing (for me) gem named
`kitchen-sync`.

I tend to use test-kitchen in a wide variety of configurations. Sometimes I'm
using it to drive Vagrant, most of the time, I'm using it drive Docker, but
there are times when I need it to drive remove instances such as EC2. One
of my biggest pain points in this last configuration is the time it takes to
copy of the cookbooks to the remote machine. If you've got a cookbook that
has many dependencies (either directly or indirectly), this is a painful process.
It is especially aggravating because you're probably only testing a change to
a single file, yet you have to wait for a billion other files that have not
changed to get copied again.

Enter [kitchen-sync](https://github.com/coderanger/kitchen-sync).  Put out
by Noah Kantrowitz (a Chef super star), This little gem saves so much time when
your doing iterative development. The initial creation of the instance still
takes time as all the files have to be copied, however your second run will
have the file copy step take only a second or two. In my case I've got one
**really nasty** cookbook that has so many dependencies it was taking 10-12
minutes **each converge**. Using kitchen-sync my subsequent runs take only a
couple seconds to copy the file.

If you are doing any Chef development using test-kitchen and remote instances,
this is a **must have**.
