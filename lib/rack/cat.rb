require "rack/mock"
require "fileutils"

module Rack
  class Cat
    def initialize(app, options = {})
      @app         = app
      @bundles     = options[:bundles]     # { "/destination/path" => [ "/array/of", "/source/paths"] }
      @destination = options[:destination] # a directory to write bundles into
      @sources     = options[:sources]     # array with source dirs
      @debug       = options[:debug]       # regenerate bundles on each request
      
      create_bundles unless @debug
    end
    
    def call(env)
      create_bundles(Rack::Request.new(env).path) if @debug
      @app.call(env)
    end
    
    private
    
    def bundle_path(request_path)
      @bundles.keys.detect { |bp| request_path.start_with?(bp) }
    end

    def create_bundles(request_path = nil)
      if request_path && bp = bundle_path(request_path)
        create_bundle(bp)
      else
        @bundles.keys.each do |bp|
          create_bundle(bp)
        end
      end
    end
    
    def create_bundle(bundle_path)
      concatenation = @bundles[bundle_path].map do |path|
        read_from_disk(path) || read_from_app(path)
      end.join("\n")
      
      write_to_disk(bundle_path, concatenation)
    end
    
    def write_to_disk(path, content)
      full_path = ::File.join(@destination, path)
      FileUtils.mkdir_p(::File.dirname(full_path))

      ::File.open(full_path, "w") do |f|
        f.write(content)
      end
    end
    
    def read_from_disk(path)
      @sources.each do |source|
        full_path = ::File.join(source, Rack::Utils.unescape(path))
        return ::File.read(full_path) if ::File.file?(full_path) && ::File.readable?(full_path)
      end
      
      return # return nil (instead of @sources) when no file found
    end

    def read_from_app(path)
      Rack::MockRequest.new(@app).get(path).body
    end
  end
end
