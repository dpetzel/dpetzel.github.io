---
categories: [Programming]
date: 2012-03-05
draft: false
tags: [JavaScript, jQuery, Cloud Zoom]
title: Cloud Zoom Is Blocking My Modal Dialog Box
type: post
---
The issue I was having is that the Cloud Zoom enhanced image was being
displayed in front of my drop down menu as well as my modal dialog box. At
first I had only noticed the issue on the drop menu, and was having a hard time
figuring out what was going on, and thought perhaps I had done something wrong
on the superfish menu. Once I noticed it was also affecting my modal dialog,
I became suspicious of cloud zoom.
<!--more-->

* I've got a page that is using a few different jQuery dependent features/functions.
* I'm using the superfish drop down menu
* I'm also using the jQuery UI Dialog for a modal dialog box
* And finally, I'm using Cloud Zoom for some image excitement


I went through and tried a few different things, and finally just disabled
cloud zoom. At that point my drop down menu was now correctly displayed over
top of the image. I spent some time looking through the cloud-zoom site with no
luck. I spent quite a bit of time googling with no luck.

I turned my attention to the jQuery UI documentation for anything that might be
a clue. I was reading through the various options and came upon the zIndex
option. I had no idea what zIndex was (I am no jQuery expert). Long story short,
I finally got to this article: http://zenverse.net/how-to-fix-superfish-dropdown-menu-that-appear-under-floating-divs-in-ie6/
So I randomly picked a stupid high zIndex (100,000), and sure enough it worked!
So the question of the day is WHY? and what is the value of zIndex I need to
use? Well on a hunch I started digging through the cloud zoom javascript and
found line 350::

```javascript
  $(this).wrap('<div id="wrap" style="top:0px;z-index:9999;position:relative;"></div>');
```

So Cloud Zoom is using 9999. Any other components that has a z-index lower
than that will be displayed behind my images. So of course, I put this to the
test. I set my z-index to 10,000 on my menu and 10,001 on my modal dialog.

A quick refresh and everything is working perfect!. zIndex... who knew...

In case you are wondering, yes I did test an iteration with the index of the
menu and modal dialog set to be lower than 9999 and as expected they were
hidden by the cloud zoom image.
