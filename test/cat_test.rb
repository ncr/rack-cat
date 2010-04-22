require "test_helper"
require "rack/cat"
require "fileutils"
 
class CatTest < Test::Unit::TestCase
  test "concatentaion of static and dynamic files" do
    env = Rack::MockRequest.env_for("/all.txt")
    app = Rack::Cat.new(
      lambda {|env| [200, {}, ["app"]]}, 
      :sources => ["test/fixtures", "test/fixtures/foo"],
      :bundles => {
        "/all.txt" => ["/foo.txt", "/bar/bar.txt", "/baz.txt", "/app.txt"]
      },
      :destination => "test/fixtures/baz/public/"
    )
    app.call(env)
    
    assert_equal "foo\nbar\nbaz\napp", File.read("test/fixtures/baz/public/all.txt")

    FileUtils.rm_r("test/fixtures/baz")
  end
end
