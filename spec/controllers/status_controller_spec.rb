require 'spec_helper'

describe StatusController do
  it "routes" do
    {:get => status_path}.should route_to("status#index")
  end

  let(:status_response) { JSON.parse(response.body) }
  it 'should indicate email as available if smtp connection succeeds' do
    Net::SMTP.should_receive(:start).with("localhost", 25)

    get :index, :only => :email

    status_response.should include({"email" => true})
  end

  it 'should indicate email as unavailable if smtp connection fails' do
    Net::SMTP.should_receive(:start).with("localhost", 25).and_raise(StandardError)

    get :index, :only => :email

    status_response.should include({"email" => false})
  end

  it 'should indicate database is available if db connection succeeds' do
    ActiveRecord::Base.stub(:connected?).and_return(true)

    get :index, :only => :db

    status_response.should include({"db" => true})
  end

  it 'should indicate database is unavailable if db connection fails' do
    ActiveRecord::Base.stub(:connected?).and_return(false)

    get :index, :only => :db

    status_response.should include({"db" => false})
  end

  it 'should indicate search is available if solr ping succeeds' do
    response = stub(:code => 200)

    HTTParty.should_receive(:get).with("#{Sunspot.config.solr.url}/ping").and_return(response)

    get :index, :only => :search

    status_response.should include({"search" => true})
  end

  it 'should indicate search is unavailable if solr returns anything except 200' do
    response = stub(:code => 500)
    HTTParty.should_receive(:get).with("#{Sunspot.config.solr.url}/ping").and_return(response)

    get :index, :only => :search

    status_response.should include({"search" => false})
  end

  it 'should indicate search is unavailable if endpoint is invalid' do
    HTTParty.should_receive(:get).with("#{Sunspot.config.solr.url}/ping").and_raise(StandardError)

    get :index, :only => :search

    status_response.should include({"search" => false})
  end

  context "jobs" do
    before(:each) do
      Timecop.freeze(2015, 10, 2)
    end

    it "should identify failed jobs if job is not processed within max age (default 15 mins)" do
      Timecop.freeze(2015, 10, 2)

      Delayed::Job.should_receive(:where).with("created_at < ?", Time.now - 15.minutes).and_return(stub(:count => 1))

      get :index, :only => :jobs

      status_response.should include({"jobs" => false})
    end

    it "should reports jobs okay if there are no stale jobs" do
      Delayed::Job.should_receive(:where).with("created_at < ?", Time.now - 20.minutes).and_return(stub(:count => 0))

      get :index, :only => :jobs, :jobs_max_age => 20

      status_response.should include({"jobs" => true})
    end

    after(:each) do
      Timecop.return
    end
  end

  it "should indicate sms is available if sms provider returns 200 OK" do
    HTTParty.should_receive(:get).with("https://twilix.exotel.in/v1/Accounts/#{Exotel.exotel_sid}/", :basic_auth => {:username => Exotel.exotel_sid, :password => Exotel.exotel_token}).and_return(stub(:code => 200))

    get :index, :only => :sms

    status_response.should include({"sms" => true})
  end

  it "should indicate status for all services by default" do
    HTTParty.stub(:get).and_return(stub(:code => 200))
    Net::SMTP.stub(:start)

    get :index

    status_response.should include("db", "email", "search", "jobs", "sms")
  end

end