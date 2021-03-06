---
categories: [General]
date: 2013-09-03
draft: false
tags: [Python, Mynt, HTML]
title: Live With Mynt
type: post
---
So I've been hearing a bit lately about static site generators. So the last
couple of nights I decided to finally do a little homework and better
understand it.
<!--more-->
So after reading about the various options out there I ended up experimenting
with several of the available Python options (Mynt, Pelican, Nikola, and Hyde).
I went with Python, as I am primarily a Windows users and I've always had an
easier time getting Python packages working on Windows than Ruby
(which is why I kept looking despite Jekyll being so popular).

I was not overwhelmed by any of the offerings, and it was clear that these are
not solutions for the "average" user. You need to small amount of technical
skill to get any of them up and running and understand their template systems.

At the end of the day I decided to go with Mynt as it seemed to be most basic.
Some of the others had more plugins and such, but for how rarely I do this,
I don't need much.

One of the other things I wanted to learn more about was using GitHub Pages
for user pages. At work I've played a fair amount with GH-Pages for project
sites,  but since I'd never done a user page, I decided I'd host my personal
site created with Mynt on my Github Personal Page. I'm not sure why, but I
don't really care for the way its implemented requiring you to understand git
branches and what not, but I've grown used to it and have learned to tolerate
it :).

One of the really cool things I found completely by accident during my
digging was https://github.com/davisp/ghp-import/. ghp-import makes it super
 easy to publish a directory of compiled content to a given Github branch.
 Once I figured this out the whole multiple branch thing becomes less annoying.
 So I configured my repo's default branch to be **source**, leaving **master**
 as the place the compiled content would end up. Then I'm able to easily push
 with a simple one-liner:

 ```shell
 ghp-import _build -p -r origin -b master
 ```

 OK.... thats enough for now, back to the interwebs to see what else I can
 learn.