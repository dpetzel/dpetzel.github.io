---
categories: [Zenoss]
date: 2013-09-07
draft: false
tags: [Zenoss, ZenPack, Travis-CI, PyPi]
title: Publishing A Zenoss ZenPack to PyPi Using Travis-CI
type: post
---

**NOTE**: It was pointed out to me that while ZenPacks are technically eggs,
it is not always safe to promote them as a standard Python module, which is
why you don't see more ZenPacks on PyPi.

So read on if you are curious about how it *might* work, but please don't
make this part of your standard ZenPack release process.
<!--more-->

I recently had the need to update the `F5 ZenPack`. It had been a while since
I had updated a Pack so I was hopeful that the process for releasing a new
pack (http://wiki.zenoss.org/Releasing_your_ZenPack) had been updated to be
a little less manual. Don't get me wrong the system that is in place is a vast
improvement of what used to exist, but I'm just not excited about how manual
the process is. Maybe I'll write up a separate page about what I dislike about
the process, but the focus on this page is not to complain about that process,
but rather show what I think is a better (more automated) solution.

So the goal I set out was with:

* I didn't want to continue to maintain two different versions of documentation
  (I keep a README.rst with the pack, but the Wiki requires wiki markup)
* I didn't want to manually upload any build artifacts
* I want to lay the ground work for some testing (I've historically done a poor
  job at adding tests to my ZenPacks, but I'm hoping to change that)

So I set out on the road of using `Travis CI` uploading `PyPi`. So the first
step I took was getting integration with `PyPi` outside of Travis. After reading
up on the documentation at http://docs.python.org/3/distutils/packageindex.html

I added the following release.sh script to my ZenPacks repo:

```bash
#! /bin/bash

# Create a .pypirc file in the home directory
echo "[distutils]
index-servers =
  pypi

[pypi]" > ~/.pypirc

echo "username: " "$PYPI_USER" >> ~/.pypirc
echo "password: " "$PYPI_PWD" >> ~/.pypirc

python setup.py sdist bdist_egg upload
rm -f ~/.pypirc
```

So what this does is read in my PyPi username and password from an environment
variable so I don't need to keep them in the repo. Additionally if someone else
ever wants to become a contributor it should allow them to use the same script

I did a one time registration of the ZenPack outside of this script, and from
there on out, I'm able to just run `sh release.sh` from the root of the repo
and it will upload the compile compile egg (which contains the version) to PyPi.

So right out of the gate, I've hit two of my three targets. But I wanted to take
it a little further. While running `sh release.sh` is pretty easy, I wanted
to see about automatically testing and upload the egg. This is where things
got a little trickier, but still not to bad...

The `Travis CI` getting started documentation is pretty indepth, so I don't want
to recreate that here, but I do want to call out you'll want to read up
how to do the encrypted environment stuff.

So after some trial and error (I'm not sure why, but it took me a while to krok
the encrypted environment variable stuff), I ended up with this `.travis.yml`.

So now everytime I push a change up to the github repo, a service hook fires
and `Travis CI` starts building my ZenPack immediatly. You can see those build
resuts here: https://travis-ci.org/ZCA/ZenPacks.community.f5

As part of the build process it will produce two egg files, one for Python2.6
(Zenoss 3.x) and one for Python 2.7 (Zenoss 4.x), and upload them automatically
to `PyPi`.

I do have to say, I was not 100% comfortable with the idea of handing over some
much private information to Travis (allowing them access to my GitHub account,
as well as trusting that their encryption keys are secure). In the end, I just
ensured I was using information I don't use on any other sites. I still
can't say I'm entirely comfortable with it, but sometimes you just have to be
a little trusting. We'll see....

The process did go smooth enough, that I intend to convert some of the other
ZenPacks I maintain and see how it goes longer term.


References:
* [F5 ZenPack](https://github.com/ZCA/ZenPacks.community.f5)
* [Travis CI](https://travis-ci.org)
* [PyPi](http://pypi.python.org)
* [.travis.yml](https://github.com/ZCA/ZenPacks.community.f5/blob/master/.travis.yml)