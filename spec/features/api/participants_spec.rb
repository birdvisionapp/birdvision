require 'request_spec_helper'

feature "Client API - Participants Spec" do

  before :each do
    page.driver.header 'HTTP_ACCEPT', 'application/json'
  end

  let(:client) { Fabricate(:client_allow_sso) }

  context "participants" do

    context "rewards information of participant" do
      scenario "should return participant rewards information" do
        user = Fabricate(:user, :status => User::Status::ACTIVE, :client => client)
        page.driver.header 'client_id', client.client_key
        page.driver.header 'client_secret', client.client_secret
        page.driver.header 'participant_id', user.participant_id
        test_scheme = Fabricate(:scheme, :client => client, :name => "BBD", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today + 45.days, :single_redemption => false)
        Fabricate(:user_scheme, :scheme => test_scheme, :user => user, :total_points => 2000, :redeemed_points => 300)
        visit(rewards_api_participants_path)
        page.should have_content({points: {total: '2,000', redeemed: '300', remaining: '1,700'}, achievements: [{scheme_name: 'BBD', total: '20,000'}]}.to_json)
      end

      scenario "should fail to return rewards information to participant with given invalid client_id and client_secret headers" do
        page.driver.header 'client_id', 'test124'
        page.driver.header 'client_secret', 'test123456'
        visit(rewards_api_participants_path)
        page.should have_content({title: "errors", status_code: 1, status_message: "Invalid client id or client secret"}.to_json)
      end

      scenario "should fail to return rewards information with given invalid participant_id header" do
        page.driver.header 'client_id', client.client_key
        page.driver.header 'client_secret', client.client_secret
        page.driver.header 'participant_id', 'p1'
        visit(rewards_api_participants_path)
        page.should have_content({title: "errors", status_code: 1, status_message: "Could not find BVC user account with ParticipantID: p1"}.to_json)
      end

      scenario "should fail to return rewards information to participant if participant is in inactive state" do
        user = Fabricate(:user, :status => User::Status::INACTIVE, :client => client)
        page.driver.header 'client_id', client.client_key
        page.driver.header 'client_secret', client.client_secret
        page.driver.header 'participant_id', user.participant_id
        visit(rewards_api_participants_path)
        page.should have_content({title: "errors", status_code: 1, status_message: "The participant is in INACTIVE status"}.to_json)
      end
    end

  end
  
end