---
categories: []
date: 2016-09-19T10:46:10-04:00
draft: false
tags: [UOKOO, webcam]
title: My New UOKOO IP Camera
type: post
---
I recently purchased a [UOKOO Webcam from Amazon](https://www.amazon.com/dp/B01ER7OCZU).
At only $40.00 I didn't have very high expectations but I was pleasantly
surprised at what I got

<!--more-->
This was a bit of an impulse buy. I had a small project I was wanted to do and
I needed an IP based camera to do it. There is not shortage of these available
on the Internet, and if you wanted to, you probably spend a full week
researching them. I was *not* in the mood for all the research on this project
and it was my wife who actually found this guy.

I won't re-iterate all the features as the Amazon product page does a good job
at that. I'm just going to run down the functionality that I experimented with.


## Installation And Setup
We had no issues with the order, the package arrived on schedule in some very
unassuming packaging.

The camera comes with a small instruction booklet and a micro USB power cord.
Its worth noting the cord is a decent length, probably 4 or 5 feet.

I was a little worried I'd need an extension cord to place it where I wanted,
but the cord was long enough to reach without one.

Getting the camera configured for my Wifi was a little sketchy. To be fair, I've
had issues with many devices connecting to my WiFi since I don't broadcast my
SSID. You have to first download the mobile app (discussed below). Once that
installed, you have to press a configuration button on the side of the unit,
which allows it to be programmed for a minute or two. If you don't succeed in
that amount of time you'll have to start over.

Once its in its programming mode, you scan a QR code with your phone and your
phone will start beeping at the camera. This series of beeps is supposed to
configure the camera. It took me about half a dozen attempts to get it to take,
but once it did take, the device was on my WiFi network.

Once it's online you can hit a browser interface

## iSmartView Pro PC Application
They don't make it overly obvious where to get the software from, but its
available at http://cd.ipcamdata.com/en/xseries.html. This PC application can
be used at no cost.

It allows you to view a number of these devices all in one window. This
software also allows you to configure a recording from the camera. You have the
ability to set the time(s) of day that you want record. It will record to the
local hardware of the machine running the software.

## iSmartViewPro Android App
Searching the Play Store for iSmartViewPro. Its very similar to the PC app, but
geared for mobile devices. This application is also free to use with the
camera.

The app will let you put 4 cameras on to your screen, each taking up a quarter
of the screen.

Outside of the browser interface, this app is the primary method of configuring
the device. You can take recordings and pictures, but I didn't exercise this
functionality very much

## Accessing From The Internet
The device allows you to stream the output via a web browser if you have Flash
installed. Its all done over TCP port 80 (as best I could tell). So I configured
a port forward on my router to send 80 to the camera. The following day, from
work, I was able to load up my public IP and watch the camera from work.

## Nightvision
The camera sports some nightvision which doesn't work all that well. When you
engagne the nightvision 3 red lights on the face of the camera light up. They
are pretty bright, so you're not going to be concealing this from anyone at night.

I had hoped to hook this up in a window, looking outward. This works great
during the day, however at night, once the night vision LEDs kick in they
product a reflection off the glass of the window so you can't see a thing

## Alarms
The device has the ability to send emails, a notification to your mobile app,
or save off to an FTP server when motion is detected. I did experiment with this
for a little while, but it didn't work very well. Every single time the alert
tripped the resulting images it sent me didn't have anyone in them. It seems
as if the delay is so high, the person or thing walking by has already cleared
the field of vision before the picture is taken

## Two Way Audio
Using the mobile app you can speak into your phone and you will indeed hear
sound from the camera. I say sound, because its barely understandable. The
volume is extremely low, and I didn't see an option to increase that. In
addition to the low volume, the voices don't sound anything like the actual
voice of the person speaking into it.

I have yet to get around to testing how well it picks up audio. Where I have it
place in my house this would be annoying, so I've left that functionalit
disabled.

## Summary
Overall I'm pleased with the purchase. This is not a device I'd build a
surveillance system around, but for the price it is a fun little device. This
is actually the first IP based camera I've purchased and being able to check out
whats going on at my house when I'm not there is a mildly addicting. It's
got me thinking about getting a kit of higher end units to let me view more
angles of my property.
