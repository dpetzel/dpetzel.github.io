---
categories: [newtworking]
date: 2017-04-02T20:00:52-04:00
draft: false
tags: [Linksys, WRT, DD-WRT, WRT1200AC]
title: Flashing DD-WRT On A Linksys WRT1200AC V2
type: post
---
This weekend I decided it was time to replace the stock firmware on my WRT1200AC v2. 
I've had the unit for a while now and it's been working well but I had a little time 
on my hands so I opted to give it a go. 
The process itself was pretty easy, but finding the right information was not. Hopefully this saves someone else some time...

<!--more-->

## The Journey
If you aren't interested in the narrative, jump down the `The Process` for the actual steps
I used to flash.

I've been using Advanced Tomato on the last couple of routers I've had so that is where I started, however I couldn't find any indication this was supported. The 1200 is not on [Shibby's list](http://tomato.groov.pl/?page_id=69). There is also a decent size thread on [linksysinfo](http://www.linksysinfo.org/index.php?threads/porting-tomato-firmware-to-other-platforms.69976/page-2) which didn't leave me with the warm and fuzzies. I finally gave up hope after failing to find it on [flashrouters.com](https://www.flashrouters.com/routers/router-types/tomato?limit=36)

I also checked support for OpenWRT, however only the [V1 is listed](https://wiki.openwrt.org/toh/linksys/wrt_ac_series) was listed so I moved to DD-WRT.

I finally started to have some hope when I found `Linksys WRT1200AC v2` listed in the [router database](https://www.dd-wrt.com/site/support/router-database). However the page simply presents you two files to download with no explanation of what you should do with them. 
On top of that these files are marked Beta. That never instills high levels of confidence.
After several minutes of googling around all things pointed to the [Peacock Thread](http://www.dd-wrt.com/phpBB2/viewtopic.php?t=51486). This is one of the most confusing set of instructions I've ever read and it left me wondering if I should really be proceeding here. I won't go into all the confusion points but lets highlight a couple:

> DON'T USE THE ROUTER DATABASE! The router database has recommended some less stable builds

uhh... OK..... Then why does it even exist?

> FOLLOW THE PROCESS FOR FLASHING YOUR ROUTER THAT IS IN THE WIKI. 
> http://www.dd-wrt.com/wiki/index.php/Installation 
> Once you have dd-wrt installed on your route

OK, fair enough, except there is one problem. The 1200 isn't on that page...


>  Read the WIKI and follow the wiki for INITIAL flashing of your router. There has been a lot of work recently to improve the wiki for broadcom devices and the wiki is now mostly up to date and using good files. Don't flash firmware based on youtube or instructions on another non dd-wrt website. Often youtube or other internet instructions are out of date/incorrect! Read and follow the instructions here in the dd-wrt wiki. 
One thing you REALLY need to look at is the procedure for installing to your router. This is extremely important as there are a lot of subtle variation

Uh... They keep hammering home to use the WIKI but its not there... 

So at this point I'm feeling skeptical that this is going to work, but what the heck, its early enough that stores are still open and the wife is away for a few hours. I've got time to buy a new one if this all goes south and I brick this thing so I press on.

# The Process
First up I did take their advice and download all the files I needed (instructions, firmware, etc) locally before proceeding.

I can't recall exactly where I found it, but I found some mentions that the version in the database might not be the latest so I started browsing the [DD-WRT FTP Server](ftp://ftp.dd-wrt.com). I finally landed in ftp://ftp.dd-wrt.com/betas/2017/03-30-2017-r31791/linksys-wrt1200acv2/ which had the files I needed.
There were two files in the directory so I grabbed them both not knowing which I needed. Turns out the only file needed was the `factory-to-ddwrt.bin`. While I'm not positive, I believe the other file (`ddwrt-linksys-wrt1200acv2-webflash.bin`) would be used I was already running DD-WRT and was looking to upgrade.

At this point I was ready to begin:

1. I disconnected all ethernet cables, except for the PC I'm using to do the flashing
1. Perform the 30-30-30 reset. After this is complete you're left with a factory reset device. Login to http://192.168.1.1 with the default password (`admin`). 
1. Navigate to Connectivity --> Basic. Click the `Choose` button and select `factory-to-ddwrt.bin`. This will take a couple minutes. Once complete this the web UI again on http://192.168.1.1. 
1. At this point DD-WRT was in fact installed and forcing me to set a password. This felt like a pointless step since I was about to 30-30-30 it again, but I played it safe and it anyway. 
1. Perform another 30-30-30 reset. I'm honestly skeptical that this is really needed at this point, but I figured 90 seconds of wasted time was better than a bricked 1200 so I complied.
1. Once it came back up I needed to do the password dance again


That's it!!. At this point it was flashed and I started re-applying my configurations for my IP addresses, port forwards, etc.

I want to be very clear that I don't believe what I did is "supported" so tread carefully, but it's been 9 hours since I did the upgrade, I've streamed some content and done misc browsing without any issues. Obviously is hard to declare success and stability after only 9 hours, so fingers crossed!






