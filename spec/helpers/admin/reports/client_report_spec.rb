require 'spec_helper'

describe Admin::Reports::ClientReport do

  context "CLIENT report" do
    include Admin::Reports::ClientReport

    it "should generate csv" do
      acme = Fabricate(:client, :client_name => "Acme", :points_to_rupee_ratio => 2)
      big_bang_dhamaka = Fabricate(:scheme, :client => acme, :name => "BBD", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today + 45.days)
      small_bang_dhamaka = Fabricate(:scheme, :client => acme, :name => "SBD", :redemption_start_date => Date.today + 6.days, :redemption_end_date => Date.today + 10.days)

      user1 = Fabricate(:user, :client => acme, :participant_id => "U1", :full_name => "First User", :activation_status => User::ActivationStatus::NOT_ACTIVATED, :status => User::Status::INACTIVE)
      user_scheme1 = Fabricate(:user_scheme, :user => user1, :scheme => big_bang_dhamaka, :total_points => 500, :redeemed_points => 200)
      user_scheme2 = Fabricate(:user_scheme, :scheme => small_bang_dhamaka, :user => user1, :total_points => 2_500, :redeemed_points => 0, :current_achievements => 2_000)
      update_level_club(user_scheme2, 'level1', 'platinum')


      csv = acme.to_csv

      csv.should include(["Client Name", "Scheme Name", "Participant ID", "Activation Status", "Activated at", "Participant Status", "Participant Name",
                          "Participant Username", "Total points uploaded", "Total points redeemed", "Final Achievement", "Rewards Redeemed"]
                         .join(","))

      csv.should include(["Acme", "BBD", "U1", "Not Activated", "", "Inactive", "First User", "acme.u1", "500", "200", "20000", "0"].join(","))
      csv.should include(["Acme", "SBD", "U1", "Not Activated", "", "Inactive", "First User", "acme.u1", "2500", "0", "2000", "0"].join(","))
    end
  end
end