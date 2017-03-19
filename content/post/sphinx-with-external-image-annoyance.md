---
title: Sphinx With External Image Annoyance
layout: post
categories:
  - Tips/Python
tags: [python, sphinx]
date: 2013-09-24
disqus_identifier: "http://www.dpetzel.info/tips/python/2013/09/24/sphinx-with-external-image-annoyance.html"
disqus_url: "http://www.dpetzel.info/tips/python/2013/09/24/sphinx-with-external-image-annoyance.html"
---

So today I was trying to clean up some of my Sphinx build warnings when
rendering this site. I got everything fixed so I had no errors or
warnings except for this little guy right here (truncated for easier
reading):
```
~/dpetzel.info.tinkerer/2011/12/16/developing_a_command_parser_based_zenpack.rst:328: WARNING: nonlocal image URI found: https://external.domain/image.png
```

I know I'm linking to an external image. I don't want to store my binary
images in my Github repo .

I search google for a bit and couldn't find anything. This was so
annoying!! I don't want these warnings every build to numb me to real
warnings so I I wanted to suppress them.

Well, since this is just Python lets get to work

```shell
$ grep -Rn "nonlocal image URI found" ~/virtualenvs/tinkerer/lib/python2.7/site-packages/
/home/dave/virtualenvs/tinkerer/lib/python2.7/site-packages/sphinx/environment.py:779:                self.warn_node('nonlocal image URI found: %s' % imguri, node)
```

So I edited line 779 in the file from:
```python
	if imguri.find('://') != -1:
 		self.warn_node('nonlocal image URI found: %s' % imguri, node)
 		candidates['?'] = imguri
 		continue
```

to end up with:
{% highlight python %}
	if imguri.find('://') != -1:
 		# self.warn_node('nonlocal image URI found: %s' % imguri, node)
 		candidates['?'] = imguri
 		continue
{% endhighlight %}

Voila! No more warning for external images. If anyone knows the
**right** way to suppress these warnings (Yes I've read all the reasons
why you shouldn't) please let me know.
