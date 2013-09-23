Adventures in Django Performance Analysis
=========================================



.. author:: default
.. categories:: Programming
.. tags:: Django, Python, Celery
.. comments::

Nothing to eye opening here but I wanted to collect some thoughs and insights
I had this week. While I'm more of an operations guy, a while back I hacked
up a `Django`_ based web application which uses `Celery`_ and `RabbitMQ`_.

.. more::

Its not an application that sees much traffic as it was created to serve a niche
internal purpose, but it does handle web requests which result in potentially
long running background tasks.

There are a few pages and process that are painfully slow. So this week I set
out to improve some of slower components of the application. I felt like I had
a pretty good idea of what sucked and why but I wanted to gather some metrics
first so I could understand if the changes I was going to make were the right
changes to make. As of today, I've not made any code changes to improve
performance, but I wanted to collect my observations after having adding some
instrumentation.

New Relic Integration
---------------------
At work `New Relic`_ has been getting a lot of buzz for the magic it works on
Java based applications. I was aware they had some `Python`_ integration, but
up until this week I had not looked too closely at it. To be fair I still don't
think I've spent enough time reading all their documentation to fully appreciate
all they have to offer, as I was pretty focused on integration with my `Django`_
application.

The first thing I noticed was my "google-foo" was failing on producing anything
useful.  I got as far as http://newrelic.com/python/django which is a great
marketing page, but I needed the technical know-how on how to hook things up.
(I'm a `New Relic`_ noob all the way around). What I thought was interesting here is
once I did find their documentation it was tremendous, so it was odd that my
searches had been coming up so dry...

I read through the bits and pieces on https://newrelic.com/docs/python/.
I was starting to get pretty excited as this looked like it was going to be really
easy. https://newrelic.com/docs/python/python-agent-integration seemed to have
all the key pieces I needed, so I got to work.

I run my application under a `virtualenv`_ so I added ``newrelic`` to my
requirements.txt and ran a quick ``pip install -r requirements.txt``. The
package was installed without any issues. No crazy dependencies and no compile
errors (which are all to uncommon when installing packages with pip).

Next up for me was getting the agent registered with my web server
(Apache running mod_wsgi). They offer several ways of doing doing things, but I
settled on the *Manual integration with code* approach. So I added the following
to my wsgi script::

   try:
       import newrelic.agent
       try:
           nr_conf = os.path.join(project_folder, "conf", "newrelic-django.conf")
           newrelic.agent.initialize(nr_conf)
       except newrelic.api.exceptions.ConfigurationError:
           logger.warn("Failed loading New Relic config: {0}".format(nr_conf))
   except ImportError:
       logger.error("Failed to import newrelic agent")
       
This deviates just a touch from their example so let me explain the key pieces
here. ``project_folder`` is a variable that was already in my wsgi_script and
is simply the path to where all my code lives. I'm storing the ``newrelic-django.conf``
in a ``conf`` sub-folder. The examples on the `New Relic`_ site worked, but for
me I wanted to be sure that if anything was wrong with the agent or the
configuration file it wouldn't hinder my apps ability to start. As a result I
wrapped their example with some try/except blocks and logging.

About 2-3 minutes after restarting Apache on my local development VM where I
was testing this, I started seeing very detailed statistics in `New Relic`_.
I was in awe for several minutes at the insane level of detail they were able
to collect including database query times and mapping out my downstream
dependencies. It was truly amazing!

I did however notice that none of my `Celery`_ tasks were getting any information.
I did recall I had read that had to be handle separately. So this lead me
to https://newrelic.com/docs/python/python-agent-and-celery. I'm running
`Celery`_ under `runit`_ so I had to update my run script. In the process I learned
a little more about runit and environment variables (I'm still pretty new to
using `runit`_). http://smarden.org/runit/chpst.8.html is where they discuss this
but for me it was not immediately clear. Here is what I did:

1. create a new directory in the *same directory* as my run script. I named it
   ``env``
2. In my ``env`` directory I created a file called ``NEW_RELIC_CONFIG_FILE``.
3. I populated ``env/NEW_RELIC_CONFIG_FILE`` with the path to my configuration
   file.

So now when `runit`_ kicks off my celeryd process it will have the proper
environment variable set.

So now it was time to update my run script. Here is what it looked like before:

.. code-block:: bash

	exec /usr/bin/env chpst -u myapps_user \
	  path_to_virtualenv/bin/python \
	  path_to_my_code/manage.py \
	  celeryd

And here is what it looked like after. As you can see not all that different:

.. code-block:: bash
	:emphasize-lines: 1-3

	exec /usr/bin/env chpst -e env -u myapps_user \
	  path_to_virtualenv/bin/python \
	  path_to_virtualenv/bin/newrelic-admin run-program \
	  path_to_virtualenv/bin/python \
	  path_to_my_code/manage.py \
	  celeryd

Restarted my service and sure enough in just a minute or two I had stats showing
up in `New Relic`_. I will say it didn't have quite the awe inspiring level of
detail that the web application had, but still pretty awesome for making 0 code
changes, and simply starting up using their wrapper.

That was it, up and running in about about 1.5 hours including time to read
the documentation. Lets ship it!!.

I rolled out my updated code to QA and started seeing **nothing**. WTF....
Trolling through the logs I found this:

.. code-block:: none

	newrelic.core.data_collector WARNING - Data collector is not contactable via the proxy host 'myproxyhost' on port 8080 with proxy user of None. This can be because of a network issue or because of the data collector being restarted. In the event that contact cannot be made after a period of time then please report this problem to New Relic support for further investigation. The error raised was SSLError(SSLError(SSLError('_ssl.c:489: The handshake operation timed out',),),).

Now I was prepared a bit for this as I knew I'd be running behind a proxy server
so I had planned for this and included proxy configuration in my configuration
INI file. Assuming I had done something wrong I reviewed the proxy related
information in https://newrelic.com/docs/python/python-agent-configuration.
Everything looked correct. Typical debugging ensues without any luck. So I
start hacking a ton of debugging output into their agent code and learned that
the HTTP end point I'm failing on is ``https://collector.newrelic.com/agent_listener/invoke_raw_method``.
Using curl from the command line I'm able to confirm proxy connectivity is
working. Several more WTF's follow.. While I don't pretend to fully understand
all the moving pieces I was able to see their agent is using the requests library
and the dictionary they were passing for proxies looked different than the
`examples on the requests site <http://www.python-requests.org/en/latest/user/advanced/#proxies>`_.

The newrelic agent was using ``{'https': 'myproxyhost:8080'}``,
however requests shows it as ``{'https': 'http://myproxyhost:8080'}``

Here is how I had my agent INI originally:

.. code-block:: ini

   proxy_host = myproxyhost
   proxy_port = 8080

So I changed it to this:

.. code-block:: ini

   proxy_host = http://myproxyhost
   proxy_port = 8080
   
After a restart everything was working fine and I was seeing stats from my
nodes behind my proxy server. Success!!. While I think this is actually a bug
in their agent code, I was happy to see I would work around it with a
configuration change.


Memcached Vs Locmem
-------------------
I've got a few instances of my application running and early on I had added some
**very** basic caching. Early on there was only a single instance so I thought
I was doing myself a favor by keeping things simple and using the ``locmem``
cache backend. When the time came to scale up to more instances I knew this was
not the best approach as cache was not being shared across instances and if
wanted to run with multiple Apache processes those processes, even though there
under the same instance of Apache, were not actually sharing cache. I should note
that the reason for adding more instances wasn't load related, but simply to
avoid having a single point of failure. So at that time I didn't explore
switching to Memcached as I didn't really want to change anything, I just
wanted more instances to avoid the SPF.

Fast-forward and I figured since I'm focused on the subject let me eliminate
what I know is an inefficiency and switch to Memcached so all my instances
are now sharing cache. Since I had recently hooked up New Relic I had some
really great statistics. I could see, on average, one of the more frequent
pages of the application were taking about 2 seconds (horrible I know.. I knew it
was slow, but was ashamed when I saw just how slow it really was).  So I updated
my configuration to use a **remote** (not on the same box) Memcached cluster.
I didn't make any other changes to code or configuration, yet as soon as I rolled
out I saw an average of about 700ms reduction in response time. That warrants
repeating.... **Doing nothing except changing from locmem to Memcached resulted
in around 700ms of reduced page load time**.

I am not suggesting that locmem is bad. In fact, when I first implemented it
made a pretty large improvement, but it was very interesting see to how much
of an improvement Memcached made, considering we were going from in process
cache to an external (across the network) cache. My take away from this was
that there are cases were a remote cache can actually be more beneficial than
a local cache, if your sharing information across many instances.


Celery apply vs apply_async
---------------------------
The last thing I poked at this week was usage of `Celery`_'s ``apply()`` method
vs ``apply_aysync``. For those that don't know the difference, ``apply_async``
will drop a message onto the queue and wait for celeryd to process it
asynchronously. Using ``apply()`` is defined as::

   Execute this task locally, by blocking until the task returns
   
I was curious what sort of overhead was involved in the process of dropping the
message onto the queue. I created a task that did no actual work::

   from celery.task import task
   
   @task
   def test_task():
       pass

After that I timed the calls to both ``apply()`` and ``apply_aysync``. On my
system, where `RabbitMQ`_ is running on the same box (so no network hops
involved in this test), ``apply()`` would run the task in about 3-4ms while
``apply_aysync`` ranged between 13-16ms with occasional anomalies of 30-34ms.

For my purposes this is plenty fast enough, but I was a little surprised to
see that level of overhead.

Summary
-------
In summary, it was an interesting set of exercises and for the most part
confirmed many of my suspicions, but its nice to finally have some real
metrics around this. Now that I'm measuring all this great stuff its time to
start improving it!


.. _Django: https://www.djangoproject.com/
.. _Celery: http://www.celeryproject.org/
.. _RabbitMQ: http://www.rabbitmq.com/
.. _Python: http://www.python.org/
.. _New Relic: http://newrelic.com/
.. _runit: http://smarden.org/runit/
.. _virtualenv: https://pypi.python.org/pypi/virtualenv


