require 'spec_helper'

describe Api::ParticipantsController do

  context "routes" do
    it "should route requests correctly" do
      {:post => registration_api_participants_path}.should route_to('api/participants#registration')
      {:get => rewards_api_participants_path}.should route_to('api/participants#rewards')
      {:post => update_info_api_participants_path}.should route_to('api/participants#update_info')
      {:post => de_activate_api_participants_path}.should route_to('api/participants#de_activate')
    end    
  end

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
    request.accept = 'application/json'
  end

  let(:client) { Fabricate(:client_allow_sso) }

  context "register participant" do

    it "should fail to registration participant with given invalid client_id and client_secret headers" do
      request.env['client_id'] = 'test123'
      request.env['client_secret'] = 'test123456'
      post :registration, :format => :json
      response.should be_ok
      User.count.should == 0
      response.body.should == {title: "errors", status_code: 1, status_message: "Invalid client id or client secret"}.to_json
    end

    it "should return exception if empty json body to register participant" do
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      post :registration, :format => :json
      User.count.should == 0
      response.should be_ok
      response.body.should == {title: "exception", status_code: 2, status_message: "795: unexpected token at ''"}.to_json
    end

    it "should check unacceptable parameters in the json body when registering participant" do
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['RAW_POST_DATA'] = {participant_id: "test1", username: "", full_name: "Test Name", email: "test@testing", mobile_number: "987654321"}.to_json
      post :registration, :format => :json
      User.count.should == 0
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: "The following parameters only can be acceptable in the JSON body to REGISTER the Participant. Acceptable parameters: participant_id, full_name, email, mobile_number, landline_number, address, pincode, and notes. Unacceptable parameters: username"}.to_json
    end

    it "should return validation errors when registering participant" do
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['RAW_POST_DATA'] = {participant_id: "", full_name: "Test Name", email: "test@testing", mobile_number: "987654321"}.to_json
      post :registration, :format => :json
      User.count.should == 0
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: ["Please enter the participant id","Email format should be valid e.g email@domain.com","Mobile number is the wrong length (should be 10 characters)"]}.to_json
    end

    it "should fail to register participant if participant_id already used" do
      user = Fabricate(:user, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['RAW_POST_DATA'] = {participant_id: user.participant_id, full_name: "Test Name", email: "test@testing.com", mobile_number: "9876543210"}.to_json
      post :registration, :format => :json
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: "The participant has already registered with ParticipantID: #{user.participant_id}"}.to_json
    end

    it "should register participant with given valid data and headers" do
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['RAW_POST_DATA'] = {participant_id: "test1", full_name: "Test Name", email: "test@testing.com", mobile_number: "9876543210", landline_number: "123456", address: "testing", pincode: "560067", notes: "test notes"}.to_json
      post :registration, :format => :json
      User.count.should == 1
      response.should be_ok
      response.body.should == {title: "ok", status_code: 0, status_message: "The participant has successfully registered"}.to_json
    end
  end

  context "rewards information of participant" do
    it "should fail to return rewards information to participant if participant is in inactive state" do
      user = Fabricate(:user, :status => User::Status::INACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      get :rewards, :format => :json
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: "The participant is in INACTIVE status"}.to_json
    end

    it "should return participant rewards information" do
      user = Fabricate(:user, :status => User::Status::ACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      test_scheme = Fabricate(:scheme, :client => client, :name => "BBD", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today + 45.days, :single_redemption => false)
      Fabricate(:user_scheme, :scheme => test_scheme, :user => user, :total_points => 2000, :redeemed_points => 300)
      get :rewards, :format => :json
      response.should be_ok
      response.body.should == {points: {total: '2,000', redeemed: '300', remaining: '1,700'}, achievements: [{scheme_name: 'BBD', total: '20,000'}]}.to_json
    end
  end

  context "update participant information" do
    it "should fail to update participant with given invalid client_id and client_secret headers" do
      request.env['client_id'] = 'test123'
      request.env['client_secret'] = 'test123456'
      post :update_info, :format => :json
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: "Invalid client id or client secret"}.to_json
    end

    it "should fail to update participant with given invalid participant_id header" do
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = 't1'
      post :update_info, :format => :json
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: "Could not find BVC user account with ParticipantID: #{request.env['participant_id']}"}.to_json
    end

    it "should return exception if empty json body to update participant information" do
      user = Fabricate(:user, :status => User::Status::ACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      post :update_info, :format => :json
      response.should be_ok
      response.body.should == {title: "exception", status_code: 2, status_message: "795: unexpected token at ''"}.to_json
    end

    it "should check unacceptable parameters in the json body when updating the participant information" do
      user = Fabricate(:user, :status => User::Status::ACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      request.env['RAW_POST_DATA'] = {participant_id: "test1"}.to_json
      post :update_info, :format => :json
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: "The following parameters only can be acceptable in the JSON body to UPDATE the Participant. Acceptable parameters: full_name, email, mobile_number, landline_number, address, pincode, and notes. Unacceptable parameters: participant_id"}.to_json
    end

    it "should fail to update participant information if participant is in inactive state" do
      user = Fabricate(:user, :status => User::Status::INACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      post :update_info, :format => :json
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: "The participant is in INACTIVE status"}.to_json
    end

    it "should return validation errors when updating participant information" do
      user = Fabricate(:user, :status => User::Status::ACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      request.env['RAW_POST_DATA'] = {full_name: "", email: "test@testing", mobile_number: "1234"}.to_json
      post :update_info, :format => :json
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: ["Full name can't be blank","Email format should be valid e.g email@domain.com","Mobile number is the wrong length (should be 10 characters)"]}.to_json
    end

    it "should update participant information with given valid data" do
      user = Fabricate(:user, :status => User::Status::ACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      request.env['RAW_POST_DATA'] = {full_name: "Update Testname", email: "updated@testing.com", mobile_number: "8876543210"}.to_json
      post :update_info, :format => :json
      user.reload
      user.full_name.should == 'Update Testname'
      user.email.should == 'updated@testing.com'
      user.mobile_number.should == '8876543210'
      response.should be_ok
      response.body.should == {title: "ok", status_code: 0, status_message: "The participant has successfully updated"}.to_json
    end

  end

  context "de-activate participant" do
    it "should fail to de-activate participant if participant is in inactive state" do
      user = Fabricate(:user, :status => User::Status::INACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      post :de_activate, :format => :json
      response.should be_ok
      response.body.should == {title: "errors", status_code: 1, status_message: "The participant is in INACTIVE status"}.to_json
    end

    it "should de-activate participant" do
      user = Fabricate(:user, :status => User::Status::ACTIVE, :client => client)
      request.env['client_id'] = client.client_key
      request.env['client_secret'] = client.client_secret
      request.env['participant_id'] = user.participant_id
      post :de_activate, :format => :json
      user.reload
      user.status.should == User::Status::INACTIVE
      response.should be_ok
      response.body.should == {title: "ok", status_code: 0, status_message: "The participant has successfully De-Activated"}.to_json
    end
  end

end