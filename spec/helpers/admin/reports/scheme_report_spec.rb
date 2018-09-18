require 'spec_helper'

describe Admin::Reports::SchemeReport do

  context "reporting per scheme" do

    it "should return report data for a point based scheme" do
      acme = Fabricate(:client, :client_name => "Acme", :points_to_rupee_ratio => 2)
      big_bang_dhamaka = Fabricate(:scheme, :client => acme, :name => "BBD")
      small_bang_dhamaka = Fabricate(:scheme, :single_redemption => true, :client => acme, :name => "SBD")

      user1 = Fabricate(:user, :participant_id => "U1", :client => acme, :full_name => "First User", :activation_status => User::ActivationStatus::ACTIVATED, :activated_at => DateTime.new(2010, 12, 23), :status => User::Status::ACTIVE)
      user2 = Fabricate(:user, :participant_id => "U2", :client => acme, :full_name => "Second User", :activation_status => User::ActivationStatus::NOT_ACTIVATED, :status => User::Status::INACTIVE)

      user1_bbd_user_scheme = Fabricate(:user_scheme, :scheme => big_bang_dhamaka, :user => user1, :total_points => 500, :redeemed_points => 200)
      user1_sbd_user_scheme = Fabricate(:user_scheme, :scheme => small_bang_dhamaka, :user => user1, :total_points => 1_500, :redeemed_points => 200, :current_achievements => 2_000)
      update_level_club(user1_sbd_user_scheme, 'level1', 'platinum')

      user2_bbd_user_scheme = Fabricate(:user_scheme, :scheme => big_bang_dhamaka, :user => user2, :total_points => 1000, :redeemed_points => 500)
      user2_sbd_user_scheme = Fabricate(:user_scheme, :scheme => small_bang_dhamaka, :user => user2, :redeemed_points => 600, :total_points => 2_500, :current_achievements => 1_000)
      update_level_club(user2_sbd_user_scheme, 'level1', 'platinum')

      Fabricate(:order_item, :order => Fabricate(:order, :user => user1), :scheme => big_bang_dhamaka, :price_in_rupees => 300)

      Admin::Reports::SchemeReport::CSV_HEADERS.should == ["Client Name", "Scheme Name", "Participant ID", "Activation Status", "Activated at", "Participant Status",
                                                           "Participant Name", "Participant Username", "Total points uploaded", "Total points redeemed", "Final Achievement", "Rewards Redeemed", "Time"]

      reporting_data_of_users_for(big_bang_dhamaka).should == [["Acme", "BBD", "U1", "Activated", "23-Dec-2010", "Active", "First User", "acme.u1", 500, 200, 20000, 300, user1_bbd_user_scheme.updated_at.try(:strftime, "%d-%b-%Y %I:%M %p")],
                                                               ["Acme", "BBD", "U2", "Not Activated", nil, "Inactive", "Second User", "acme.u2", 1000, 500, 20000, 0, user2_bbd_user_scheme.updated_at.try(:strftime, "%d-%b-%Y %I:%M %p")]]

      reporting_data_of_users_for(small_bang_dhamaka).should == [['Acme', 'SBD', 'U1', 'Activated', "23-Dec-2010", "Active", 'First User', "#{user1.username}", 1_500, 200, 2000, 0, user1_sbd_user_scheme.updated_at.try(:strftime, "%d-%b-%Y %I:%M %p")],
                                                                 ['Acme', 'SBD', 'U2', 'Not Activated', nil, "Inactive", 'Second User', "#{user2.username}", 2_500, 600, 1000, 0, user2_sbd_user_scheme.updated_at.try(:strftime, "%d-%b-%Y %I:%M %p")]]
    end

  end
end