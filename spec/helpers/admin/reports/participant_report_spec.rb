require 'spec_helper'

describe Admin::Reports::ParticipantReport do

  context "participant report" do
    include Admin::Reports::ParticipantReport
    before :each do
      @user1 = Fabricate(:user)
      @user2 = Fabricate(:user)
      Fabricate(:user_scheme, :user => @user1, :scheme => Fabricate(:scheme))
    end

    def all
      [@user1]
    end

    it "should generate csv" do
      csv = to_csv
      csv.should include(["Participant Id", "Username", "Full Name", "Email", "Mobile Number", "Activation Status", "Status", "Client",
                          "Schemes(Points)", "Created On"].join(","))

      csv.should include([@user1.participant_id,
                          @user1.username,
                          @user1.full_name,
                          @user1.email,
                          @user1.mobile_number,
                          @user1.activation_status,
                          @user1.status.titleize,
                          @user1.client_name,
                         ].join(","))
    end
  end
end