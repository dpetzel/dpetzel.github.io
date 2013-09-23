Sending an SMTP email in Python 3
=================================



.. author:: default
.. categories:: Programming
.. tags:: Python, SMTP, email
.. comments::

This took me far longer than it should have, and while I'd like to blame shotty documentation and sparse examples it was probably my own stupidity causing the issue. Whatever the case maybe I wanted to jot down my results as I'm sure I'll need to do this again.

.. more::

I'd like go on a rant about how much harder this was than it should be and how an easier module should exist. However, the fact that I can't write an easier module lends itself to the "Don't Complain, Contribute" motto, so I'll settle on the belief that its not easier for a good reason, and maybe one day if I ever get really good at Python I can make it easier.

For the time challenged people who don't want to read, here is the condensed version with no explanation::

  import smtplib
  import string

  subject = "My Wicked Cool Subject Line"
  to = "rec1@domain1.com,rec2@domain.com".split(",")
  from = "sender@domain.com"
  body_text = "Enter the contents of your body here"
  body = "From: {0} \r\n \
          To: {1} \r\n \
          Subject: {2} \r\n \
          {3} \r\n".format(FROM, ", ".join(TO), SUBJECT, text)
  server = smtplib.SMTP("YourSMTPServerName",YourSMTPServerPort)
  server.login("you@yourdomain.com","yourpassword")
  server.set_debuglevel(1)
  server.sendmail(from, to, body)
  server.quit()

For those that want a little more explanation, aside from reading the python docs, I've added some quick notes around some of the stuff that is not uber obvious. So the first thing we need is the SMTP module::

  import smtplib 

Then we'll need the string module. Quite likely there are other ways to accomplish this, but this is the method I took::
  
  import string

The following is using some variables to over-simplify the whole mess, but you should get the idea::

  subject = "My Wicked Cool Subject Line"
  #add as many as you need separated by commas
  to = "rec1@domain1.com,rec2@domain.com".split(",")
  from = "sender@domain.com"
  #obviously you can dynamically generate this variable.
  body_text = "Enter the contents of your body here"
  #didn't bother to read all the gory details, but from what I gather
  # This approach is used to set some SMTP headers, and munch everything
  # into a single body entity.
  body = "From: {0} \r\n \
          To: {1} \r\n \
          Subject: {2} \r\n \
          {3} \r\n".format(FROM, ", ".join(TO), SUBJECT, text)
  #This part is pretty cool. It uses the new format method in lieu of the
  # older %s approach. Honestly I find it simpler than the %s approach.

  server = smtplib.SMTP("YourSMTPServerName",YourSMTPServerPort)
  #You only need if your not connecting to the defacto standard 25.

  #This line is needed because my SMTP server requires Auth. If yours doesnt
  # Omit this.
  server.login("you@yourdomain.com","yourpassword")

  #I'm curious and wanted to see what was happening. So I flipped on debugging.
  server.set_debuglevel(1)
  # Fire Away!
  server.sendmail(from, to, body)
  #End you session.
  server.quit()


