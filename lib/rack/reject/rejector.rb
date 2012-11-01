module Rack
  module Reject
    class Rejector
      ##
      # Reject Request if block.call(request) returns true
      #      
      def initialize(app, options = {}, &block)
        default_options = {
          :code => 503, # HTTP STATUS CODE
          :msg => "503 SERVICE UNAVAILIBLE", # Text that is displayed a response unless param :file is used
          :headers => {}, # overwrite headers
          :retry_after => nil, # send retry after header, see http://webee.technion.ac.il/labs/comnet/netcourse/CIE/RFC/2068/201.htm
          :html_file => nil # Path to html file to return, e.g. Rails.root.join('public', '500.html')
        }        
        
        @app, @options, @block = app, default_options.merge(options), block
      end
      
      def call(env)
        request = Rack::Request.new(env)
        opts = @options.clone
        reject?(request, opts) ?  reject!(request, opts) : @app.call(env)
      end 
      
      ##
      # Check whether the request is to be rejected
      def reject? request, opts
        @block.call(request, opts)
      end 
      
      ##
      # Reject the request
      def reject! request, opts
        [status(opts), headers(opts), response(opts)]
      end
      
      def headers opts
        headers = {}
        if opts[:html_file].nil?
          headers['Content-Type'] = 'text/plain; charset=utf-8' 
        else 
          headers['Content-Type'] = 'text/html; charset=utf-8' 
          headers['Content-Disposition'] = "inline; filename='reject.html'"
          headers['Content-Transfer-Encoding'] = 'binary'
          headers['Cache-Control'] = 'private'
        end
        headers['Retry-After'] = opts[:retry_after] unless opts[:retry_after].nil?
        
        headers.merge(opts[:headers])
      end
      
      def status opts
        opts[:code]
      end
      
      def response opts
        if opts[:html_file].nil?
          Array.wrap(opts[:msg])
        else
          ::File.open(opts[:html_file], "rb")
        end
      end
    end
  end
end