require 'test_helper'
require 'rack/test'
require 'resque/server'

describe "Resque web" do
  include Rack::Test::Methods

  def app
    Resque::Server.new
  end

  # Root path test
  describe "on GET to /" do
    before { get "/" }

    it "redirect to overview" do
      follow_redirect!
    end
  end

  # Global overview
  describe "on GET to /overview" do
    before { get "/overview" }

    it "should at least display 'queues'" do
      assert last_response.body.include?('Queues')
    end
  end

  describe "With append-prefix option on GET to /overview" do
    reverse_proxy_prefix = 'proxy_site/resque'
    Resque::Server.url_prefix = reverse_proxy_prefix
    before { get "/overview" }

    it "should contain reverse proxy prefix for asset urls and links" do
      assert last_response.body.include?(reverse_proxy_prefix)
    end
  end

  # Working jobs
  describe "on GET to /working" do
    before { get "/working" }

    it "should respond with success" do
      assert last_response.ok?, last_response.errors
    end
  end

  # Failed
  describe "on GET to /failed" do
    before { get "/failed" }

    it "should respond with success" do
      assert last_response.ok?, last_response.errors
    end
  end

  # Stats
  describe "on GET to /stats/resque" do
    before { get "/stats/resque" }

    it "should respond with success" do
      assert last_response.ok?, last_response.errors
    end
  end

  describe "on GET to /stats/redis" do
    before { get "/stats/redis" }

    it "should respond with success" do
      assert last_response.ok?, last_response.errors
    end
  end

  describe "on GET to /stats/resque" do
    before { get "/stats/keys" }

    it "should respond with success" do
      assert last_response.ok?, last_response.errors
    end
  end

  describe "also works with slash at the end" do
    before { get "/working/" }

    it "should respond with success" do
      assert last_response.ok?, last_response.errors
    end
  end

  describe "on GET to /queues/:queue/size" do
    before do
      get "/queues/default/size"
    end
    it "should return the size of the queue" do
      assert last_response.body, {data: 0}.to_json
    end
    it "should increase the count when the number of jobs increase" do
      3.times do |n|
        Resque::Job.create(:default, 'default', 20, '/tmp')
        assert last_response.body, {data: n}.to_json
      end
    end
  end

end
