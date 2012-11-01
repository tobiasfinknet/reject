Reject
======

Rack Module to reject unwanted requests.

Sometimes you don't want to reject incoming requests. Use cases could be:

  - block page for maintenance reasons
  - blacklist resources or clients
  - enforce usage limits (you might want to use [datagraph/rack-throttle](https://github.com/datagraph/rack-throttle) for that)
  
Usage with Rails
----------------

**Add to Gemfile**:

    gem 'reject', :github => 'tobiasfinknet/reject'

I still have to check that rubygems stuff, maybe i'll have to rename the gem to avoid annoying  :require parameters in the Gemfile

**Add to &lt;environment>.rb**

Basically you still have to write the conditions for rejection on your own. The rest is handled by this gem. This example would deny access to all clients with IPs other than 127.0.0.1:
 
    config.middleware.use "Rack::Reject::Rejector" do |request, opts|
      request.ip != "127.0.0.1"
    end

Parameters and defaults
-----------------------

    default_options = {
      :code => 503, # HTTP STATUS CODE
      :msg => "503 SERVICE UNAVAILIBLE", # Text that is displayed as response unless param :file is used
      :headers => {}, # overwrite headers
      :retry_after => nil, # send retry after header
      :html_file => nil # Path to html file to return, e.g. Rails.root.join('public', '500.html')
    } 

For the retry_after param see [the rfc](http://webee.technion.ac.il/labs/comnet/netcourse/CIE/RFC/2068/201.htm) for examples.

You can set all options in the middleware command and override them on the opts-hash that is passed to your rejection-block.

Examples
--------
**Deliver funny random error page on every 5th request (rails)**

	config.middleware.use "Rack::Reject::Rejector", :html_file => Rails.root.join('public', 'iis.html'), :code => 500 do |request, opts|
      (0...5).to_a.sample == 0
    end
	
Use only on april-fools day. Don't forget to create iis.html.

**Limit the number of incoming requests per ip (rails)**

    config.middleware.insert_before 'Rack::Lock',"Rack::Reject::Rejector", :code => 403 do |request, opts|
      allowed_requests_per_second = 0.5
      max_lockout_seconds = 100
      threshold = 20
      now = Time.now
      
      client_info = Rails.cache.read(request.ip) || [now, 0.0]
      last_visit = client_info[0]
      activity = client_info[1]
      
      activity = [activity - (now - last_visit) * allowed_requests_per_second, 0.0].max + 1.0
      activity = [activity, (max_lockout_seconds * allowed_requests_per_second) + threshold].min
      
      
      opts[:retry_after] = ((activity - threshold) / allowed_requests_per_second).ceil.to_s
      opts[:msg] = "Your last request was only #{(now - last_visit)} seconds ago. \nCome back in #{opts[:retry_after]} seconds."
      
      Rails.cache.write(request.ip, [now, activity])
      
      activity > threshold
    end

Make sure to use a fast cross-instance rails cache for this, e.g. [memcache store](http://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html).
Make also sure to configure to configure allowed requests per second and threshold to your needs, that depends strongly on if assets are delivered through rails or through an external webserver.
Also there can be lots of non-malicious ajax requests which should not be blocked.

With config.middleware.insert_before, the rejection code is called at the very beginning of the request handling. 
This will lower the used resources to a minimum.

ToDo
----
  - Write lots of awesome tests

Acknowledgements
-----------------
  - [datagraph/rack-throttle](https://github.com/datagraph/rack-throttle) was the inspiration to limit requests, although it didn't fit our needs
  - [ASCIIcasts](http://asciicasts.com/episodes/151-rack-middleware) for explaining how to write a rack module :-)
  - A strange customer whos performance test consists of a bunch of testers pressing F5 on the slowest pages (that normally wouldn't be requested more often than 5 times a minute)

