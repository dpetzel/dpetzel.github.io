---
categories: []
date: 2013-09-08
draft: false
tags: [Nodejs, Uptime, Heroku]
title: Running Uptime on Heroku
type: post
---
For today's adventure I've decided to finally get my hands dirty with
[Heroku](http://heroku.com). I've know about it for a while now, and have gone
so far as reading some of the documentation, however I've never actually
tried using it. So today, I decided to change that.
<!--more-->

**NOTE**: If you don't really care how I got there, skip to the "Condensed"
section for the bare bones info.


## Long Version
So my first question was what should I run. I'm not really in a coding
mood today so I figured I would pick something someone else has already
written. Earlier this week a colleague of mine turned me onto `Uptime`_
so I figured, what the heck its as good as any.

After a little more digging, I found that there were enough free pieces
to Heroku that I should be able to run this experiment at no charge.
Bonus!!

So the reading started with:

* https://devcenter.heroku.com/articles/getting-started-with-nodejs
* https://gist.github.com/amree/5884081

That link the gist was superhelpful, however I didn't really care for
the fact that the credentials would be stored in the configuration
file. After a little more digging I ended up on http://lorenwest.github.io/node-config/latest/.
The key piece of information on this page was:

> Environment variables can be used to override file configurations. Any environment variable that starts with $CONFIG_ is set into the CONFIG object.

I recalled reading in the Heroku docs that I could set environment
variables for my application. So at this point I feel like I've got
enough information to get started. Here we go...

The first thing I did was sign up for a Heroku account from their
front page. I must say this was one of the easiest signup processes
I have ever seen. I also thought it was interesting (only because it was
different) that during the sign up process you don't create your password
until AFTER you get your verification email.

Next I installed the Heroku toolbelt (I'm doing this testing on a
Linux Mint workstation):

```shell
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
```

That couldn't have been any No more errors!! I think we are in business finally.easier.. So now I cloned the Uptime github repo:
```shell
git clone https://github.com/fzaninotto/uptime.git
cd uptime
```

Next I logged into Heroku:
```shell
heroku login
```

This is a brand new test workstation I'm using so I didn't have any
ssh keys configured yet. Heroku appears to take care of that as well:
```shell
Could not find an existing public key.
Would you like to generate one? [Yn] Y
Generating new SSH public key.
Uploading SSH public key /home/dave/.ssh/id_rsa.pub... done
Authentication successful.
```

I'm assuming had I already had keys, this would have been skipped..
From there I setup the application in Heroku:
```shell
heroku create my-uptime
Creating my-uptime... done, stack is cedar
http://my-uptime.herokuapp.com/ | git@heroku.com:my-uptime.git
Git remote heroku added
```

So things interesting at this step happened:

1. The name I originally chose came back with `!    Name is already taken`.
   This seems to indicate that two people can't have the same application.
   Interesting, but no big deal as some simple name prefixing would easy
   solve this
2. It automatically created a new git remote for me. This was pretty cool
   In some of the reading I did I kept seeing references to
   `git push heroku master`, and I was wondering why none of them
   references creating the remote. Now I know.

Now we need to add in support for MongoDB (which uptime uses). This was
the first actual issue I ran into. I'm sure it was in the docs somewhere
but I must have missed it:
```shell
heroku addons:add mongolab
Adding mongolab on my-uptime... failed
 !    Please verify your account to install this add-on
 !    For more information, see http://devcenter.heroku.com/categories/billing
 !    Verify now at https://heroku.com/verify
```
Hitting that verify page I was prompted for my credit card info. Wait
a minute... I could have sworn I read that the `Mongo HQ` addon said
I could use the **MongoHQ Sandbox** for *free*.... And then I found this:
https://devcenter.heroku.com/articles/account-verification

> It becomes a requirement once you wish to use add-ons other than
  postgresql:dev or pgbackups:plus–even if the add-ons are free. This is because
  some features (most notably outgoing email and  custom domains) carry a
  potential for abuse.

OK, that seems fair. I accommodated and gave them my CC info. Now lets
try adding Mongo support again:
```shell
heroku addons:add mongolab
Adding mongolab on my-uptime... done, v3 (free)
Welcome to MongoLab.  Your new subscription is being created and will be available shortly.  Please consult the MongoLab Add-on Admin UI to check on its progress.
Use `heroku addons:docs mongolab` to view documentation.
```

Much better!! Next I created the **Procfile**. Which seems to instruct
Heroku *how* to run the application:
```shell
echo "web: node web.js" > Procfile
git add Procfile
git commit -m "adding Procfile"
```

So this is where my path and that of the gist I was following started
to diverge a little bit. The gist talks about hacking up the config
file, while I want to use environment variables. So the first thing
I did was fetch my mongo connection info:
```shell
heroku config
=== my-uptime Config Vars
MONGOLAB_URI: mongodb://heroku_app########:randomchars@host.mongolab.com:12345/heroku_app########
```

From that I'm able to figure out the following connection information

* Database Host = host.mongolab.com
* Database Port = 12345
* Database User = heroku_app########
* Database Password = randomchars
* Database Name = heroku_app######## (Seems to match my username, not
  sure if that is always the case or not)

OK, so from here I know I can see my username will be `heroku_app########``
and my password will be ``randomchars``. Now lets set those in environment
variables so I can safely commit my stuff to github without giving
away the keys to the kingdom:
```shell
heroku config:set NODE_ENV=production
heroku config:set $CONFIG_mongodb.server=host.mongolab.com:12345
heroku config:set $CONFIG_mongodb.database=heroku_app########
heroku config:set $CONFIG_mongodb.user=heroku_app########
heroku config:set $CONFIG_mongodb.password=randomchars
```

OK, In theory that should handle our configuration. I think I'm ready
to push the app:
```shell
git push heroku master
... a bunch of output ending in..

-----> Compiled slug size: 24.3MB
-----> Launching... done, v9
       http://my-uptime.herokuapp.com deployed to Heroku

To git@heroku.com:my-uptime.git
 * [new branch]      master -> master
```

OK that seems to have gone smoothly, I guess its time to start it:
```shell
heroku ps:scale web=1
Scaling web dynos... done, now running 1
```No more errors!! I think we are in business finallyNo more errors!! I think we are in business finally.

OK, seems like it should be running...:
```shell
heroku ps
=== web (1X): `node web.js`
web.1: crashed 2013/09/08 16:20:03 (~ 5m ago)
```

Also confirmed, I couldn't hit the application on the default port of
8082... So now we dive into what went wrong.... Running ``heroku --help``
yields there is a logs subcommand. Amongst the chaos of that output I
find this line:
```shell
Error: Cannot find module '/app/web.js'
```

Turns out there is a comment on that gist which indicates we've used
the wrong js module. Lets fix that up and re-push:
```shell
echo web: node app.js > Procfile
git add Procfile
git commit -m "fixing module name"
git push heroku master
..the same lots of output as last time we pushed
```

Is it working now?:
```shell
heroku ps
=== web (1X): `node app.js`
web.1: crashed 2013/09/08 16:32:11 (~ 1m ago)
```

doh!. what now...Using ``heroku logs``. I find this line now:
```shell
MongoDB error: failed to connect to [localhost:27017]
```

Hmmm.. Localhost and 27017 (the default mongodb port). Neither of those
are the values I set in my environment variables.... Lets look into
that. Running `heroku config` shows that my named spaced ENV vars
didn't actually take, and instead they were all applied at the root
level:
```shell
heroku config
=== my-uptime Config Vars
.database:    heroku_app########
.password:    randomchars
.server:      host.mongolab.com:12345
.user:        heroku_app########
```

So back to the drawing board on assigning those config values...
A re-read of http://lorenwest.github.io/node-config/latest/ yields
I'm dumb and can't read.... I should use underscores not dots to
delimit my vars... Lets try this again:
```shell
heroku config:set $CONFIG_mongodb_password=randomchars
Setting config vars and restarting my-uptime... failed
 !    Config var key must not be empty.
```

OK, doesn't like that... I'm guessing the leading dollar sign in the
docs shouldn't be used when setting this, trying it a different way:
```shell
heroku config:set CONFIG_mongodb_password=randomchars
Setting config vars and restarting mp-uptime... done, v13
CONFIG_mongodb_password: randomchars
```
Looks better...:
```shell
heroku config
=== mp-uptime Config Vars
.database:               heroku_app########
.password:               randomchars
.server:                 host.mongolab.com:12345
.user:                   heroku_app########
CONFIG_mongodb_password: randomchars
```

Before we go any further, lets clean up my previous mess before I forget
about it:
```shell
heroku config:unset .database .password .server .user
Unsetting .database and restarting my-uptime... done, v14
Unsetting .password and restarting my-uptime... done, v15
Unsetting .server and restarting my-uptime... done, v16
Unsetting .user and restarting my-uptime... done, v17
```

Perfect, mess removed, now lets set up the new ones...:
```shell
heroku config:set CONFIG_mongodb_server=host.mongolab.com:12345 CONFIG_mongodb_datbase=heroku_app######## CONFIG_mongodb_user=heroku_app########
Setting config vars and restarting my-uptime... done, v18
CONFIG_mongodb_database: heroku_app########
CONFIG_mongodb_server:   host.mongolab.com:12345
CONFIG_mongodb_user:     heroku_app########
```

Running ``heroku logs`` yields the same issue:
```shell
MongoDB error: failed to connect to [localhost:27017]
```

Clearly I'm not doing something right with these environment variables
Some trial and error that isn't all that beneficial ensues...
After a couple hours of back tracking and seconding guessing, I finally
figured this out.... It turns out that the vFrom the terminal::ersion of the
config module that supports the environment variable stuff is newer than what
is declared in uptime's package.json so it was being ignored!!.
So edit package.json and replaced:

```shell
"config":    "0.4.15",
with
"config":    "0.4.27",
```

And I also figured out by looking through the node-config code that the
env var prefix should be **CONFIG** not **$CONFIG**.

So lets get things rolling again.... First ensure are ENV vars are set:
```shell
heroku config:set CONFIG_mongodb_server=host.mongolab.com:12345 CONFIG_mongodb_datbase=heroku_app######## CONFIG_mongodb_user=heroku_app######## CONFIG_mongodb_password=randomchars
```

And now we have to push our application update using our new package.json:
```shell
git add package.json
git commit -m "bump config dependency"
git push heroku master
..the same lots of output as last time we pushed
```

And what do you know, I can hit the web interface via http://my-uptime.herokuapp.com.
Progress!! But all is not perfect yet..`heroku logs` yields:
```shell
[Error: http://localhost:8082/api/checks/needingPoll resource not available: connect ECONNREFUSED]
```

Lets see about fixing that up:
```
heroku config:set CONFIG_monitor_apiUrl='http://my-uptime.herokuapp.com/api'
```

No more errors!! I think we are in business finally.

## Condensed Version
Clone the Repo::
```shell
git clone https://github.com/fzaninotto/uptime.git
cd uptime
```

Log into Heroku::
```shell
heroku login
```

Create the app::
```shell
heroku create my-uptime
```

Add Mongo support::
```shell
heroku addons:add mongolab
```

Show Mongo Connection Info::
```shell
heroku config
```

Set connection info into environment variables (to keep them out of
configuration files) as well as other config options::
```shell
heroku config:set CONFIG_mongodb_server=host.mongolab.com:12345 CONFIG_mongodb_datbase=heroku_app######## CONFIG_mongodb_user=heroku_app######## CONFIG_mongodb_password=randomchars CONFIG_monitor_apiUrl='http://yourapp.herokuapp.com/api'
```

Edit package.json and replace::
```shell
"config":    "0.4.15",
with
"config":    "0.4.27",
```

Create the Procfile::
```shell
echo web: node app.js > Procfile
```

Deploy it::
```shell
git add .
git commit -m "adjustments"
git push heroku master
```

Start it up with one dyno (the free tier)::
```shell
heroku ps:scale web=1
Scaling web dynos... done, now running 1
```

Verify::
```shell
heroku logs --tail
```