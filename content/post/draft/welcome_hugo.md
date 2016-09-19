---
categories: []
date: 2016-09-19T10:47:07-04:00
draft: false
tags: []
title: Welcome Hugo
type: post
---
Well... I've gone and done it again. I've decided to switch the platform I am
using to generate this site. This time around I'm going with [Hugo](https://gohugo.io)
<!--more-->

A long while back I had switched over to using Jekyll for generating the content
for this site. After that I had taken an extended break from posting content
to the site, however I'll soon be taking on a new role, which I expect will
result in me learning a whole bunch of new things that I'll want to capture here.

So... I brushed off the dust, and invoked my good old rake task I used to start
a new post. And in typical Ruby fashion, I had gem related errors. While Ruby
maybe a pretty popular language, I find dealing with Gems
(specifically dependencies) to be a never ending losing battle. Once again,
despite having a Gemfile.lock to start from, I was getting Gem version
conflicts. I've been down this road at least a 100 times before so I was sure I
*could* resolve the issue, but I was simply to annoyed to deal with it. So like
anyone in our industry, instead of just taking the 10 minutes to fix the problem
at hand, I decided to spend the rest of my day learning and implementing something
new.. That's where Hugo enters the picture.

I'm by no means a `golang` fanboy, but I do appreciate that it ships its binaries
without any external dependencies. I've written a small utility using it as well
so while I'm far from proficient, it is a language I have some experience with.

The thought of never needing to deal with another `Gemfile`, or `requirements.txt`
was enough to get me investigating. Here are some of the highlights on why I
opted to start down this path:

* The documentation site is well organized and comprehensive. While its too
  early to know if it will answer all the questions I might have, it certainly
  has a lot of stuff to get you started.
* The getting started guide makes it look super easy to get started.
* No external package dependencies.

What's listed below is not intended to be a *how-to* document, but rather just
capturing some of the challenges I personally encountered.

## Themes
Hugo has done a good job with both the theme system, and the themes themselves.
When it comes to creating aesthetic looking websites I have zero skills. I am
completely dependent on others for this. As a result, a platform with good
themes is important to me. Enter http://themes.gohugo.io/, which has a good
collection to start with. I spent *way* to much time trying to decide which one
I liked best.

Once I had the theme I wanted, there were some things I wanted to change. In
theory, the system is designed in such a way that you can add override templates
to your `layouts` directory. I did do this in a few cases, but found myself
falling back to just editing the actual theme. Since I had placed the theme into
the same repo as the content for the site, and I was not directly pointing to an
external copy, this was the fastest way (even if fastest is not always best). Since
I wasn't sure yet if this platform was going to stick I took the low road here.

The one place I did find lacking on the template system was the parameter
documentation. Each template is free to use any number of parameters from your
site's configuration file, however a large number of them don't document what
the available parameters they support are.

## Content Conversion
I don't have a lot content so this one is not critical to me, but I did explore
it simply out of curiosity. There are two tools listed on https://gohugo.io/tools/
for migrating data from Jekyll. I gave them both a shot, and while both did create
*valid* output files, some of the Jekyll specific tags were still in the resulting
markdown files so you'd see the actual tags when viewing the rendered page.

I ended up just manually doing this since I have such a small amount of content.
I could see this be challenging for someone with a large volume of content though.

## Syntax Highlighting
There are a few approaches that Hugo takes to code syntax highlighting. They go
into details about this at https://gohugo.io/extras/highlighting.

I started off by using the server-side integration with Pygments. Since I have
such little content I was not worried about the performance implications
discussed.

This was relatively simply to setup, however this statement was a little
frustrating:

> You can explore the different color styles on pygments.org after inserting some example code.

That link will bring you to the site, but good luck trying to find the available
styles (`pygmentsstyle`) that you can choose from. After some exploring of
their site I found myself on http://pygments.org/docs/styles/.
There is a little snippet at the bottom of the page that you can run to get the
list of styles. To the best of my knowledge, this is the only way to get that
list, and even when you run it, you have no clue what they look like. Pygments
could really benefit from some sort of gallery showing off the built-in styles.

Here is the list of styles I saw after a fresh install of pygments:
```python
>>> from pygments.styles import get_all_styles
>>> list(get_all_styles())
['manni', 'igor', 'lovelace', 'xcode', 'vim', 'autumn', 'vs', 'rrt', 'native', 'perldoc', 'borland', 'tango', 'emacs', 'friendly', 'monokai', 'paraiso-dark', 'colorful', 'murphy', 'bw', 'pastie', 'algol_nu', 'paraiso-light', 'trac', 'default', 'algol', 'fruity']
```

Overall I couldn't find a style I actually liked, so I moved onto the client
side highlighting.

I gave [Highlight.js](http://highlightjs.org/) a run first. The provided
instructions were simple enough to get it up and running, but once again I wasn't
really sold on the look. My biggest annoyance (which I spent more time on then I
care to admit) was that it would line wrap all the code. I found some others with
the same issue and attempted a workaround, which resulted in a scroll bar on every
single block, even those that didn't need it. Rather than keep messing around
with this, I moved on to [Prism](http://prismjs.com/).

Prism took a little more to get up and running. There isn't some CDN endpoint you
can just point to. Instead you have to select all the languages and features you
want to use. This results in a couple minified files for you to download. I had
no clue what things I would want so I selected everything. This results in a
file that is close to 280K so this isn't ideal long term, but should get me up
and running quickly.

After wiring this up my code blocks had a look and feel that I really liked, with
one very small annoyance. After each line I could see a *very small* `lf`. As it
turns out I had included the `Show Invisibles` plugin (since I had selected all).
So I regenerated my download using everything *expect* invisibles, and that
fixed that issue.

So at this point I'm sticking with Prism as my code highlighting solution.

## Publishing To GitHub Pages
The Hugo site has a good tutorial at https://gohugo.io/tutorials/github-pages-blog/
but this didn't fit *exactly* how I wanted to do things.

I am hosting this site as a *personal* site, rather than a *project* site
which means github expects to see the rendered content on the *master* branch
rather than the *gh-pages* branch. Since they have some native support for
Jekyll, the source is kept on master and just automatically rendered.

One of the side effects of switching to Hugo however is that you need to build
your site yourself (using the `hugo` command) and then push the **rendered**
content up to the master branch. I tackled this in the following way:

* I tagged my master branch as-is so I can come back to it later as needed
* I then created a new **hugo** branch (`git checkout -b hugo`)
* I removed all the non-hugo cruft that had accumulated over the years, leaving
  me with just the files needed for Hugo.
* I ensured my `CNAME` file is in Hugo's `static` directory. This is the magic
  that allows one to host their own domain name on Github.
* I then wiped out everything **except** my `.git` folder on my `master` branch
* At this point, on the `hugo` branch I run `hugo` to generate my site into the
  *public* subdirectory
* Now we can run `git subtree push --prefix public origin master`. This will take
  the contents of the `public` directory and push to the **root** of the `master`
  branch.

Using this approach is a bit of hybrid of two methods listed on the Hugo site.
I like this method best as I don't need to have the rendered content and source
in two different repositories. In the GitHub UI, I changed the default branch to
Hugo, so now I simply work all the time in my Hugo branch and never touch master,
expect when pushing out updates.

There is a great little `deploy.sh` example on their site that I adopted to me
my work flow above, so now whenever I add new content I simply run `sh build.sh`
and my changes are committed to the `hugo` branch, built, and pushed live



