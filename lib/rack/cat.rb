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
      
      create_bundles
    end
    
    def call(env)
      create_bundles if @debug
      @app.call(env)
    end
    
    private
    
    def create_bundles
      @bundles.each do |bundle, paths|
        concatenation = paths.map do |path|
          read_from_disk(path) || read_from_app(path)
        end.join("\n")
        
        write_to_disk(bundle, concatenation)
      end
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
