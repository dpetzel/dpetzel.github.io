Chef Minitest Handler Cookbook 1.0.0 Released
=============================================

.. author:: default
.. categories:: none
.. tags:: Chef, Ruby, Minitest, Cookbook
.. comments::

The open source world is truly an amazing thing... This week the Chef
`Minitest Handler Cookbook`_ released version 1.0.0. The version number
itself is probably not all that significant, but the project itself is 
significant to me.

You see, about a year and a half or so ago we started down the road of implementing
Chef at may current employer. At that time, I'd never written a line of Ruby, 
had never heard of rpsec, and didn't even know the first thing about writing
cookbooks.

As we started down this road minitest seemed to be "the way to test". With this
in mind I started learning and implementing a few minitests in a couple simple
cookbooks. At first I felt like it was just extra work and although it was the
right thing to do I wasn't really **sold** that it was worth the effort.

Then one day, I had to work on a cookbook someone else had wrote. Given I was
still a Ruby noob I wasn't overly excited about this, but it had to be done.
I found that the author had written some minitests, and all of a sudden the
light bulb went off! The tests they had wrote were my safety net. I could make
my changes and with a reasonable level of assurance be sure I didn't break
something. Awesome!!

OK cool, but what does that have to do with anything? Turns out a lot (for
me at least). This cemented my believe in minitests and it was shortly
after that I had to do some work on a cookbook that would run on a Windows node.
Much to my dismay the Chef `Minitest Handler Cookbook`_ didn't support 
windows!!

So I moaned and complained a bit (It is a general annoyance of mine that Windows
is so neglected in the Open source community), then realized I should stop
being a jack-ass and contribute back.. So thats where I entered the picture.

I hacked up some stuff and sent over a `PR <https://github.com/btm/minitest-handler-cookbook/pull/15>`_. bryanwb_ was **super** helpful and while he probably could have just
fixed it himself in about 3 seconds he answered a lot of my dumb ruby and Chef
related questions. After some back and forth we had a version of the PR that
he liked and he accepted it. 

OK fine whatever, a PR accepted, I'd had some other PRs on other things accepted
before, but what happened next surprised me. bryanwb_ actually added me to
the author list in the readme file. Author?!?! I contributed like 3 lines
and had to ask more questions than I provided answers!.

Anyway over time I submitted a few more things and then one day bryanwb_ hits
me up. He is having a baby is concerned about the available time he'll have to
work on this project. He asks if I'd like to assist. I've pushed my own stuff
up before, but this marks the first time I've been invited to existing project.

I was hesitant for a couple reasons, but I did ended up agreeing to help out, and
as of this week I've actually been granted collaborator status for this cookbook
on the Opscode community site.

I know for those of you out there that live and breath open source this is a 
daily occurrence, but for me it was pretty cool to be able to contribute back 
to a project I find useful.

.. _`Minitest Handler Cookbook`: https://github.com/btm/minitest-handler-cookbook
.. _bryanwb: https://github.com/bryanwb
