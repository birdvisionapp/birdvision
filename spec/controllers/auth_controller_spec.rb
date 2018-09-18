require 'spec_helper'

describe AuthController do

  context "routes" do
    it "should route requests correctly" do
      {:get => '/auth/bvc/authorize'}.should route_to('auth#authorize')
      {:get => '/auth/bvc/access_token'}.should route_to('auth#access_token')
      {:get => '/auth/bvc/user'}.should route_to('auth#user')
      {:get => '/auth/bvc/check_token'}.should route_to('auth#check_token')
    end
  end

  login_user

  it "should fail to authorize client with given invalid client_id" do
    get :authorize, {:client_id => 'abc123444'}
    response.should be_ok
    response.body.should == {title: "errors", status_code: 1, status_message: "Invalid client id"}.to_json
  end

  it "should fail to authorize client and access_grant if redirect_uri not present" do
    client = Fabricate(:client)
    access_grant = Fabricate(:access_grant, :created_at => 3.days.ago)
    get :authorize, {:client_id => client.client_key}
    response.should be_ok
    response.body.should == {title: "errors", status_code: 1, status_message: "Please present the redirect uri / callback url"}.to_json
  end

  it "should fail to authorize client and access_grant if participant_id scope not present" do
    client = Fabricate(:client)
    access_grant = Fabricate(:access_grant, :created_at => 3.days.ago)
    get :authorize, {:client_id => client.client_key, :redirect_uri => 'http://test.client.com'}
    response.should be_ok
    response.body.should == {title: "errors", status_code: 1, status_message: "Please present the ParticipantID in scope"}.to_json
  end

  it "should fail to authorize client and access_grant with invalid participant_id" do
    client = Fabricate(:client)
    access_grant = Fabricate(:access_grant, :created_at => 3.days.ago)
    participant_id = 'test1'
    get :authorize, {:client_id => client.client_key, :redirect_uri => 'http://test.client.com', :scope => {:participant_id => participant_id}}
    response.should be_ok
    response.body.should == {title: "errors", status_code: 1, status_message: "Could not find BVC user account with ParticipantID: #{participant_id}"}.to_json
  end

  it "should fail to authorize client and access_grant with inactive participant" do
    client = Fabricate(:client)
    user = Fabricate(:user, :participant_id => 'test1', :status => User::Status::INACTIVE, :client => client)
    get :authorize, {:client_id => client.client_key, :redirect_uri => 'http://test.client.com/callback', :scope => {:participant_id => 'test1'}}
    response.should be_ok
    response.body.should == {title: "errors", status_code: 1, status_message: "The participant is in INACTIVE status"}.to_json
  end

  it "should authorize client and access_grant with given client_key and participant_id" do
    client = Fabricate(:client)
    user = Fabricate(:user, :status => User::Status::ACTIVE, :participant_id => 'test1', :client => client)
    redirect_uri = 'http://test.demo.com'
    get :authorize, {:client_id => client.client_key, :redirect_uri => redirect_uri, :scope => {:participant_id => user.participant_id}}
    response.should redirect_to client.access_grants.last.redirect_uri_for(redirect_uri)
  end

  it "should fail to authenticate with given invalid client_id and client_secret" do
    get :access_token, :client_id => 'ab1234', :client_secret => 'ab12345'
    response.should be_ok
    response.body.should == {title: "errors", status_code: 1, status_message: "Invalid client id or client secret"}.to_json
  end

  it "should fail to authenticate access_grant with given valid client_id and client_secret and invalid code" do
    client = Fabricate(:client)
    get :access_token, :client_id => client.client_key, :client_secret => client.client_secret, :code => '123456abc'
    response.should be_ok
    response.body.should == {title: "errors", status_code: 1, status_message: "Could not authenticate access code"}.to_json
  end

  it "should authenticate access_grant with given valid client_id client_secret and code" do
    client = Fabricate(:client)
    access_grant = Fabricate(:access_grant, :client => client)
    get :access_token, :client_id => client.client_key, :client_secret => client.client_secret, :code => access_grant.code
    response.should be_ok
    response.body.should_not == {title: "errors", status_code: 1, status_message: "Could not authenticate access code"}.to_json
  end

  it "should return access_token refresh_token and expires_in with given valid client_id client_secret and code" do
    client = Fabricate(:client)
    access_grant = Fabricate(:access_grant, :client => client)
    get :access_token, :client_id => client.client_key, :client_secret => client.client_secret, :code => access_grant.code
    response.should be_ok
    response.body.should == {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}.to_json
  end

  it "should return user information as json string" do
    get :user
    response.should be_ok
    expected_user_info = {
      :provider => 'bvc',
      :id => @user.id.to_s,
      :info => {
        :username  => @user.username,
        :email     => @user.email
      },
      :extra => {
        :full_name  => @user.full_name
      }
    }
    response.body.should == expected_user_info.to_json
  end

end
