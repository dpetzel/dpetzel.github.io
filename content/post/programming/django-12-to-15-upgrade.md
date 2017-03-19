---
layout: post
title: "Django 1.2 to 1.5 Upgrade"
categories:
  - Programming
tags: [Django, Python]
date: 2013-10-10
---

Recently I kicked off an effort to perform a long over due upgrade of the
version of Django I am using on a project. Without getting into all the gory
details of why, I need to upgrade from Django 1.2 to 1.5. Technically I don't
really have to go to 1.5, but I figure since I'm going to be messing with it
anyway I should probably just get current. This post will journal my adventure
down this road for better or worse. Just to satisfy curiosity, I did test
going from 1.2 to 1.5 directly and as expected things blew up horribly.

Since I knew a ton of stuff had changed my plan attack was going to be to step
through each an upgrade to each major version between 1.2 and 1.5 rather than
attempting to jump straight there. I intend to run my tests with the ``-Wall``
flags so I can see all the deprecation warnings. Then I'll tackle each
deprecation warning one at a time. There is likely a more efficient means of
doing this sort of thing, but its been so long since I've messed with this
project I'm going to need some time to get reacquainted anyway.

<span class="note"> **NOTE**
	To protect the innocent, any proprietary information include class names,
	file names, paths etc have been stripped from the code snippets.
</span>

## 1.2.7 to 1.3.7
This wen't really smooth for me. All my unit tests passed and I didn't see
anything immediately broken. There were a few deprecation warnings that I needed
to address however.

```console
	./django/core/cache/__init__.py:83: PendingDeprecationWarning: settings.CACHE_* is deprecated; use settings.CACHES instead.
  PendingDeprecationWarning
```

This one was pretty cut and dry as the 1.3 release notes had alerted me to this
one: https://docs.djangoproject.com/en/dev/releases/1.3/#caching-changes.
Simply changing the structure of that configuration item and all was well.

Next up was

```console
	/filename.py:14: DeprecationWarning: A Field class whose get_db_prep_value method hasn't been updated to take `connection` and `prepared` arguments.
  class MyModelClass(models.Field):
```

A little google foo later and I ended up on http://www.djangopro.com/2011/03/deprecation-warning-with-get_db_prep_value-for-django-1-3/. The advise was to update to a newer version of ``django-picklefield``. I reviewed the
dependencies I had defined in the my ``requirements.txt`` and I was using
'0.3.0', which was newer than the '0.1.9' version recommended in the article,
and also appears to be the most current version available on pypi.python.org.

With that dead end out of the way I then found https://docs.djangoproject.com/en/1.3/howto/custom-model-fields/#django.db.models.Field.get_db_prep_value.

So I updated my ``get_db_prep_value`` as follows.
Old:

```python
	def get_db_prep_value(self, value):
```

To:

```python
	def get_db_prep_value(self, value, connection, prepared=False):
```

Kicked another test run. No more deprecation warning and tests are all passing!

Next up:

```console
	./site-packages/Crypto/Util/randpool.py:40: RandomPool_DeprecationWarning: This application uses RandomPool, which is BROKEN in older releases.  See http://www.pycrypto.org/randpool-broken
  RandomPool_DeprecationWarning)
```

It wasn't really clear to me what I was supposed to do with this information,
so I figured I'd start simple and upgrade the version of pycrypto I'm using
from 2.3 to the latest available 2.6. This did *not* help.. I really have no
clue what to do with this. Since its not coming out directly from a Django
module, I'm going to ignore it for now....

Last up was

```console
	./site-packages/django/test/simple.py:28: PendingDeprecationWarning: DjangoTestRunner is deprecated; it's functionality is indistinguishable from TextTestRunner
  PendingDeprecationWarning
```

I recalled there was something about this in the release notes so I reviewed
https://docs.djangoproject.com/en/dev/releases/1.3/#djangotestrunner. Near as
I can tell there is nothing I need to do here, and Django itself will handle
this cleanup in coming versions.

That concludes my 1.2.7 to 1.3.7 upgrade. I ended up keeping the updated version
of pycrypto just because, so all and all pretty easy so far and only about 2
hours burned on that step.

## 1.3.7 to 1.4.8
With that section out of the way onto reading the 1.4 release notes to see
what gotchas I need to look out for. Based on the information in the release
notes here are the items I expect will require some attention:


* https://docs.djangoproject.com/en/dev/releases/1.4/#django-conf-urls-defaults
* https://docs.djangoproject.com/en/dev/releases/1.4/#django-contrib-admin
* https://docs.djangoproject.com/en/dev/releases/1.4/#updated-default-project-layout-and-manage-py

An initial test run after upgrading, but before any changes, is showing that the
media stuff is indeed an issue, and I have several deprecation warnings related
to items addressed in the release notes. This isn't going to be as easy as the
jump to 1.3.7 was...

I'm opting to tackle the broken things first, and then I'll address the
deprecation warnings. So first up I've made a few customizations to my
settings.py file.

* I added `django.contrib.staticfiles` to my `INSTALLED_APPS`
* Next I renamed my *media* folder to *static*. I don't have user uploaded media
  so this folder was for the purpose of static assets. And based on the
  documentation media is intended to be used for user generated content.
* I added `STATIC_URL = '/static/'` to my `settings.py`
* Updated my templates to use the new static template tag as described in
  https://docs.djangoproject.com/en/dev/howto/static-files/

While a bit tedious, that wasn't to bad. At this point all of my tests are still
passing, but I do have some ``PendingDeprecationWarning`` warnings to deal with.
I suppose since the are Pending, I could procrastinate, but I'm in here now, so
biting the bullet and going after them..

First up

```console
   ./site-packages/django/core/management/__init__.py:455: PendingDeprecationWarning: The 'execute_manager' function is deprecated, you likely need to update your 'manage.py'; please see the Django 1.4 release notes (https://docs.djangoproject.com/en/dev/releases/1.4/).
  PendingDeprecationWarning)
```
My imports worked out in such a way that I didn't need to relocate the manage.py
file so all I did was swap out the contents as outlined in https://docs.djangoproject.com/en/dev/releases/1.4/#updated-default-project-layout-and-manage-py

Alas, something busted though. After swapping out the contents of manage.py I
ended up with errors when trying to kick off my tests. I'm using the
django-jenkins app for my tests.

```console
   ./virtualenv/bin/python -Wall my_project/manage.py jenkins
   Unknown command: 'jenkins'
   Type 'manage.py help' for usage.
```

I didn't see anything immediately obvious jump out at me so I started by
updating from django-jenkins 0.11.1 to 0.14.0. No improvment (but I'm gonna
keep the newer version just the same).

Upon further inspection of ``manage.py --help`` I noticed alot of the subcommands
were missing. In fact all I saw were the ``[django]`` ones. So I moved my
``manage.py`` up one directory as discussed in the readme and all the subcommands
reappeared, including jenkins. So that was good, but the crappy things is
all my tests started failing... So into the weeds of import cleanup I go..
This turned out to be much easier than I thought. All I needed was to change
ROOT_URLCONF = 'urls'` to ROOT_URLCONF = 'my_project.urls'` and all of
tests started passing again. Added bonus, my PendingDeprecationWarning was gone.

Next up

```console
   ./site-packages/django/conf/__init__.py:75: DeprecationWarning: The ADMIN_MEDIA_PREFIX setting has been removed; use STATIC_URL instead.
  "use STATIC_URL instead.", DeprecationWarning)
```

This one is easy enough, I had already added STATIC_URL when I fixed up things
earlier, so I just removed ADMIN_MEDIA_PREFIX from my settings.py

It appears in the process of cleaning up some of the media stuff I also cleared
up some of the other DeprecationWarning messages. So at this point all my tests
are passing and no DeprecationWarning messages (aside from
``RandomPool_DeprecationWarning`` from earlier that I opted to ignore). Onto
the final leg! Total time in this leg minus distractions was about 2.5 hours

## 1.4.8 to 1.5.4
Upon an initial pass through the 1.5 release notes I was feeling pretty good
as I didn't see anything in there I though would affect me. My tests said
otherwise (**80% failure rate**). The common theme seemed to be:

```python
   from django.views.generic.simple import direct_to_template, redirect_to
   ImportError: No module named simple
```

Hmm.... obviously I missed the memo somewhere...Turns out I didn't put two and
two together back in the my 1.3 steps as its called out there
https://docs.djangoproject.com/en/dev/releases/1.3/#function-based-generic-views.
Not to sure why I didn't get any deprecation warnings along the way but oh well
lets get that fixed up.

http://stackoverflow.com/questions/11428427/no-module-named-simple-error-in-django
was the only remotely useful link I came up with in the first couple minutes
of searching. The common thread seems to stem from my urls.py file.

It seems I have a sprinkling of ``direct_to_template`` and ``redirect_to`` being
used. Its fairly clear that I need to switch from *Function-based generic views*
to *Class-based generic views*, and as luck would have it the documentation has
an awesome mapping to pull that off at https://docs.djangoproject.com/en/1.3/topics/generic-views-migration/.

So here is what I did to my urls.py.

* Replaced ``from django.views.generic.simple import direct_to_template, redirect_to``
  with ``from django.views.generic.base import TemplateView, RedirectView``
* Replaced ``redirect_to`` references with RedirectView as outlined in that
  migration page
* Replace ``direct_to_template`` references with TemplateView as outlined in
  that migration page

First I had something like this (some legacy stuff to handle when URLs changed)

```python
   (r'^base_prefix/(?P<new_url>.*)$', redirect_to, {'url': '/%(new_url)s'}),
   changed to
   (r'^base_prefix/(?P<new_url>.*)$', RedirectView.as_view(url={'url': '/%(new_url)s'})),
```

That one seemed easy enough, however the next one is nastier.. Making it worse
was it was something I didn't write so I had to figure out the previous
functionality first, before I could move forward. So I had a line that looked
like ``(r'^bar', direct_to_template, {'template': 'foo/bar.html'}, 'bar'),``

It took me a bit to figure out that the last *bar* was actually just a
`named url pattern <https://docs.djangoproject.com/en/1.2/topics/http/urls/#naming-url-patterns>`_

So a simple switch of that call over to ``(r'^bar', TemplateView.as_view(template_name='foo/bar.html'), 'bar'),``
and we're moving along.

Next up is more generic view good times

```python
   from django.views.generic import list_detail
   ImportError: cannot import name list_detail
```

In my case this actually turned out to be an unused import, so I simply
removed it.

From there I had to a bunch of conversions of my url template tags as outlined
in the release notes. So I had a lot of references like
{% raw %}`{% url myproject.myapp.views.someview arg1%}`{% endraw %} and I had to change those to
{% raw %}`{% url "myproject.myapp.views.someview" arg1%}`{% endraw %}.

At this point I'm back to 100% testing pass rate and a single (simple)
deprecation message to handle:

```console
   ./site-packages/django/conf/__init__.py:147: PendingDeprecationWarning: The TEMPLATE_DIRS setting must be a tuple. Please fix your settings, as auto-correction is now deprecated.
     PendingDeprecationWarning)
```

I wish they were all this easy. I went from:

```python
   TEMPLATE_DIRS = os.path.join(PROJECT_DIR, 'templates')
   to
   TEMPLATE_DIRS = (os.path.join(PROJECT_DIR, 'templates'),)
```

## Conclusion
Overall the process wasn't terrible, but it was certainly not a cake walk either.
By the time it was all said and done, it took me about 2 days (including
randomizations and interruptions). As usual the Django documentation was
invaluable in being to pull this off.

The app has been running for a few days now and so far no unexpected explosions,
however I should note I have been getting some random reports of CSRF errors
since the upgrade (1 or 2 reports a day). Overall most people are having no
issues, and I haven't gotten too deep into that investigation, but it is
certainly new behavior.
