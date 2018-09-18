require 'request_spec_helper'

feature "Authentication Spec - Single Sign On" do
  context "auth" do
    
    context "authorize action" do
      scenario "should authorize client and access grant with given valid client key and participant_id" do
        client = Fabricate(:client_allow_sso)
        user = Fabricate(:user, :status => User::Status::ACTIVE, :client => client)
        visit(oauth_authorize_path(:client_id => client.client_key, :redirect_uri => 'http://test.client.com/callback', :scope => {:participant_id => user.participant_id}))
        visit(user.access_grants.last.redirect_uri_for('http://test.client.com/callback'))
      end

      scenario "should fail to authorize if client id is not valid" do
        visit(oauth_authorize_path(:client_id => 'test1234'))
        page.should have_content({title: "errors", status_code: 1, status_message: "Invalid client id"}.to_json)
      end

      scenario "should fail to authorize if redirect uri is not present" do
        client = Fabricate(:client_allow_sso)
        visit(oauth_authorize_path(:client_id => client.client_key, :redirect_uri => ''))
        page.should have_content({title: "errors", status_code: 1, status_message: "Please present the redirect uri / callback url"}.to_json)
      end

      scenario "should fail to authorize if participant_id scope is not present" do
        client = Fabricate(:client_allow_sso)
        visit(oauth_authorize_path(:client_id => client.client_key, :redirect_uri => 'http://test.client.com/callback'))
        page.should have_content({title: "errors", status_code: 1, status_message: "Please present the ParticipantID in scope"}.to_json)
      end

      scenario "should fail to authorize if invalid participant_id present" do
        client = Fabricate(:client_allow_sso)
        access_grant = Fabricate(:access_grant, :created_at => 3.days.ago)
        participant_id = 'test1'
        visit(oauth_authorize_path(:client_id => client.client_key, :redirect_uri => 'http://test.client.com/callback', :scope => {:participant_id => participant_id}))
        page.should have_content({title: "errors", status_code: 1, status_message: "Could not find BVC user account with ParticipantID: #{participant_id}"}.to_json)
      end

      scenario "should fail to authorize inactive participant" do
        client = Fabricate(:client_allow_sso)
        participant_id = 'test1'
        user = Fabricate(:user, :participant_id => participant_id, :status => User::Status::INACTIVE, :client => client)
        visit(oauth_authorize_path(:client_id => client.client_key, :redirect_uri => 'http://test.client.com/callback', :scope => {:participant_id => participant_id}))
        page.should have_content({title: "errors", status_code: 1, status_message: "The participant is in INACTIVE status"}.to_json)
      end
    end

    context "access token action" do
      scenario "should fail to return access token if client id and client secret are not valid" do
        visit(oauth_access_token_path(:client_id => 'test123', :client_secret => 'test123456'))
        page.should have_content({title: "errors", status_code: 1, status_message: "Invalid client id or client secret"}.to_json)
      end

      scenario "should fail to return access token if access code is not valid" do
        client = Fabricate(:client_allow_sso)
        visit(oauth_access_token_path(:client_id => client.client_key, :client_secret => client.client_secret, :code => 'test-code'))
        page.should have_content({title: "errors", status_code: 1, status_message: "Could not authenticate access code"}.to_json)
      end

      scenario "should return access token if client id client secret and access code are valid" do
        client = Fabricate(:client_allow_sso)
        access_grant = Fabricate(:access_grant, :client => client)
        visit(oauth_access_token_path(:client_id => client.client_key, :client_secret => client.client_secret, :code => access_grant.code))
        page.should have_content({:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}.to_json)
      end
    end

    context "check access token action" do
      scenario "should fail to check access token if client id is not valid" do
        visit(oauth_authorize_path(:client_id => 'test1234'))
        page.should have_content({title: "errors", status_code: 1, status_message: "Invalid client id"}.to_json)
      end
      scenario "should fail to check access token if access token is invalid" do
        client = Fabricate(:client_allow_sso)
        visit(oauth_check_token_path(:client_id => client.client_key, :access_token => 'test-access-code'))
        page.should have_content({title: "errors", status_code: 1, status_message: "Could not authenticate access token"}.to_json)
      end
      scenario "should check access token and auto login if client id and access token are valid" do
        client = Fabricate(:client_allow_sso)
        user = Fabricate(:user, :client => client)
        access_grant = Fabricate(:access_grant, :client => client, :user => user)
        visit(oauth_check_token_path(:client_id => client.client_key, :access_token => access_grant.access_token))
        @user = access_grant.user
        login_as @user
        visit(schemes_path)
        within('#myAccount .user-name') do
          page.should have_content user.full_name
        end
        current_url.should include(schemes_path)
        click_link("Logout")
        current_url.should include(@user.client.client_url)
      end
    end

  end
end