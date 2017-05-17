---
categories: [cloud]
date: 2017-05-16T21:38:27-04:00
draft: false
tags: []
title: "Free SSL Courtesy Of Cloudflare"
type: post
---

I was recently listening to an episode of [Security Now](https://www.grc.com/securitynow.htm)
when I heard them mention that Cloudflare has a free tier. While I've never
personally used their service I've heard about it a ton of times. Hearing that
they have a free tier peaked my interest so I went exploring.

<!--more-->

I won't re-hash what Cloudflare is, they do have plenty of their own marketing
material on their [website](https://www.cloudflare.com/). I've always known
them to be a bit of a hybrid between a CDN and guarding sites against DDOS attacks.

They do in fact do those things and more, but I was surprised to find out 
that their free Tier includes free SSL.

Now, if your reading this page then you've probably already guessed there really
is not anything on this site that warrants DDOS protection or requires SSL, but hey
why not if its free?

The setup process was very simple. After creating my new account they provided
me a couple of DNS name servers, and they automatically imported all my existing
records from my current zone. I then updated my NS records to the name servers
they suggested. As with all things DNS, some waiting then occurred...

While I was waiting on DNS TTLs to expire and propagation to occur I started
browsing through all the options I had available to me in the free account. I
won't go into all of them, but there were a couple I leveraged:

* I enabled SSL of course. This was so easy it was almost comical. They set up
  my domain as an additional SAN (Subject Alternate Name) on a shared certificate.
  If you're interested you can inspect the SANs value on the certificate and see
  who else you are sharing the certificate with.

* I also turned on automatic HTTPS rewrites. This is a neat feature that actually
  inspects your response payloads and changes and HTTP references to HTTPS (or 
  at least that is how I understood the description).

* Auto minification of resources. I'll simply quote their description: 
  `Reduce the file size of source code on your website.`

* While Github Pages has always been super reliable for my needs, Cloudfare has
  an 'Always Online' feature, which basically holds onto cached copies of your
  site in case your backend origin goes down. This would be a pretty handy feature
  if you were hosting a site out of basement, or some other low cost hosting
  provider.

* Always use HTTPS page rule. Page rules are a really powerful feature, and one
  you find on most CDNs. I was surprised to see that you're given a small set of
  page rules to implement as you see fit. I opted to use one of my rules to ensure
  SSL is enforced on the site. If someone requests a page via HTTP, they will
  be redirected to the same page via HTTPS.

There are a ton of other features available so I'd strongly suggest signing up
for an account taking it for a test drive yourself. They really have made being
more secure crazy easy.

