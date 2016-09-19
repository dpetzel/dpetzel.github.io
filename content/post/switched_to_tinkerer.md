---
categories: [General]
date: 2013-09-23
draft: false
tags: [Python, Tinkerer, HTML, Sphinx]
title: Switched To Tinkerer
type: post
---
For anyone that might have been following along I've been trying out different
solutions for static site generation of this site. I'd been running `Pelican`
for a bit, but I was getting annoyed a bit with the limited directives. I've
gotten used to `Sphinx` at work for some project documentation and I wanted
to see if I could leverage some of that. A little googling later and I found
`Tinkerer` which is based on Sphinx but adds some workflow around the process
to make blogging with `Sphinx` easier.

So I've made the switch and what you are reading now was generated with Tinkerer.
I didn't have very much content yet so I just manually moved everything over,
although from what I saw if you had a lot of content it would be pretty easy
to whip up a script to do the transfer. The big difference for me was that
Pelican had you organize your posts by category, while Tinkerer has you organize
them by date. Aside form that they seemed to have roughly the same features
with Tinkerer having full Sphinx support.

We'll see if I continue to like it as time goes on. Thats all for now.

References:
* [Pelican](http://docs.getpelican.com/en/3.2/)
* [Sphinx](http://sphinx-doc.org/)
* [Tinkerer](http://tinkerer.me/)
