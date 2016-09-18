Chef Minitest and Slow Starting Web Application
===============================================



.. author:: default
.. categories:: Chef
.. tags:: Chef, Minitest
.. comments::

As I have started to become proficient with `Chef`_ I've also gotten used to 
using the `minitest-chef-handler`_ for writing integration tests for my
cookbooks. This quick post is to capture an approach I've grown to like for
doing HTTP tests of slow starting web applications. I've noticed that many
services will return from an `/sbin/service mysapp start` well before
the application has fully started and is accepting HTTP connections. 

.. more::

Originally I taken a very naive approach of timing how long the app took 
to startup, adding some arbitrary number of seconds and then just sleeping that
long before testing. This is of course a stupid approach and now that I've
gotten my feet wet with both `Chef`_ and Ruby I've learned of a really simply
approach to poll the service frequently and eventually giving up or succeeding.

Here is an example of the approach I am using these days

.. code-block:: ruby
	:linenos:

	require 'minitest/spec'
	require "net/http"
	
	describe_recipe 'mycookbook::myrecipe' do
	  include MiniTest::Chef::Assertions
	  include MiniTest::Chef::Context
	  include MiniTest::Chef::Resources
	  it "listens on the desired HTTP Port" do
	    begin
	      tries ||= 12
	      http_port = node[:myapp][:http_port]
	      response = Net::HTTP.get_response(node[:ipaddress], "/", http_port)
	    rescue
	      Chef::Log.info("HTTP listner is not available yet")
	      sleep(5)
	      retry unless (tries -= 1).zero?
	    end
	    response.must_be_kind_of(Net::HTTPOK)
	  end
	end

So lets break this down a bit:

* The first couple of lines are boiler plate imports. We will be leveraging
  some spec tests and using the net/http library in our tests.
* Line 4 starts a describe_recipe block (which ends on 20). 
* Lines 5-7 include some bits from ``Minitest::Chef``. In general you should
  move these out to a helper module, but thats out of the scope of this post.
  For the purposes of this post just know you need to have them in order for
  this to work properly (I actually think the only one that is really required
  is ``MiniTest::Chef::Context``, but all the examples you find tend to include
  all 3, so I'm leaving them as I don't believe there is much harm in including
  and not using them.
* Line 8 starts another block (which ends on line 19) which is essentially a 
  description of what we will be testing.
  
All of the items I just described are pretty generic for tests. They are
not directly related to the purpose of this post, but I include them for the
purpose of a complete example. Now lets look a little closer at the bits that
do the test:

.. code-block:: ruby
	:linenos:

	begin
	  tries ||= 12
	  http_port = node[:myapp][:http_port]
	  response = Net::HTTP.get_response(node[:ipaddress], "/", http_port)
	rescue
	  Chef::Log.debug("HTTP listner is not available yet")
	  sleep(5)
	  retry unless (tries -= 1).zero?
	end
	response.must_be_kind_of(Net::HTTPOK)
  
By wrapping everything in a begin/rescue block we can leverage Ruby's built-in
``retry`` statement which I also just recently learned about and has allowed
me to cleanup a good bit of self-rolled retry logic I've written.

I'm certainly no Ruby expert so the following explanation is how I understand
these pieces to work:

* Line 2 reads "Use the current value of the variable ``tries``. If the variable
  is not currently set, start with a value of **12**".
* Next we are going to fetch the HTTP port from a node attribute. I've seen examples
  were folks bake the HTTP port into the test, but I prefer using a node attribute
  so that my recipe can configure the application on that port and my test will
  use that same port. In the future if I ever change the port, I don't need
  to update the test.
* Line 4 is going to invoke an HTTP request to the path of "/" on the local node
  using its IP address (rather than localhost or 127.0.0.1).
  
Now comes the real magic. When something goes wrong (IE the application is not
accepting HTTP connections yet) we hit the rescue block. When that happens the
following occurs:

* Log a debug level message that we haven't finished starting yet
* Wait for 5 seconds
* And finally the magic wand in the equation... Line 8 reads "decrement the
  value of the tries variable by one (12 - 1 = 11). After decrementing the
  variable check if the variable is equal to 0. If it is not, retry the code
  that was in the begin section (lines 2-4).
  
So this block will check if the application is accepting HTTP connections once
every 5 seconds for a maximum of 12 tries (one minute). If at
any point we get an HTTP response, it stops trying. Additionally if we have
not gotten a response in 12 attempts we also stop trying.

This allows us to not wait for 60 seconds when the app usually takes 10 seconds
to start, but may sometimes take 25-30 seconds.

Finally, line 10 registers the assertion with minitest. We are asserting
that the response is going to be instance of `Net::OK <http://www.ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTPOK.html>`_.
Had we hit our maximum number of retries this would have been nil and failed.
Additionally if for some reason we got some sort of HTTP error this would
also fail.

So as I mentioned earlier there are other ways to accomplish this but I like
this approach as its pretty easy to understand for someone that doesn't know
Ruby all that well (ME!), and has the benefit of not waiting too much longer
than necessary when waiting for a service to start.

.. _Chef: http://www.opscode.com/chef/
.. _minitest-chef-handler: https://github.com/calavera/minitest-chef-handler
