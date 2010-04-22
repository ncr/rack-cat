require "rake/testtask"
 
task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*_test.rb']
    t.verbose = true
  end
end

task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rack-cat"
    gem.summary = "Rack middleware to concatenate yor assets (static, dynamic and remote)"
    gem.description = "Rack middleware to concatenate yor assets (static, dynamic and remote). Use it to serve your javascripts and stylesheets faster!"
    gem.email = "jacek.becela@gmail.com"
    gem.homepage = "http://github.com/ncr/rack-cat"
    gem.authors = ["Jacek Becela"]
    gem.add_dependency "rack"
    gem.add_development_dependency "rack-test"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
