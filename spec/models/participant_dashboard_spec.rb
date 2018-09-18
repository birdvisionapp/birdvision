require 'spec_helper'

describe ParticipantDashboard do

  context "Leader board" do
    let!(:current_user) { Fabricate(:user, :full_name => "current_user") }
    let!(:scheme_3x3) { Fabricate(:scheme_3x3) }
    let!(:current_user_scheme) { Fabricate(:user_scheme, :user => current_user, :scheme => scheme_3x3, :current_achievements => 1000) }
    let!(:participant_dashboard) { ParticipantDashboard.new(current_user) }

    it "should include two users above and below current user" do
      5.times { |index| Fabricate(:user_scheme, :scheme => scheme_3x3, :current_achievements => 400*(index+1)) }

      expected_json = [{:id => 1, :scheme_name => "Scheme",
                        :user_achievements => [{:name => "test user", :achievements => 1600, :self => false},
                                               {:name => "test user", :achievements => 1200, :self => false},
                                               {:name => "current_user", :achievements => 1000, :self => true},
                                               {:name => "test user", :achievements => 800, :self => false},
                                               {:name => "test user", :achievements => 400, :self => false}]
                       }]


      participant_dashboard.leaderboard_data.should == expected_json
    end

    it "should return info for all users of current users scheme" do
      scheme1 = Fabricate(:scheme_3x3)
      Fabricate(:user_scheme, :user => current_user, :scheme => scheme1, :current_achievements => 2000)

      participant_dashboard.leaderboard_data.size.should == 2
      participant_dashboard.leaderboard_data.collect { |scheme| scheme[:scheme_name] }.should include(scheme1.name)
      participant_dashboard.leaderboard_data.collect { |scheme| scheme[:id] }.should include(scheme1.id)
    end

    it "should return only schemes that have started and redemption has not ended" do
      Fabricate(:user_scheme, :user => current_user,
                :scheme => Fabricate(:scheme_3x3, :start_date => 1.day.ago.to_date, :end_date => Date.today,
                                     :redemption_start_date => Date.tomorrow, :redemption_end_date => 3.days.from_now.to_date))
      Fabricate(:user_scheme, :user => current_user,
                :scheme => Fabricate(:scheme_3x3, :start_date => 5.days.ago.to_date, :end_date => 4.days.ago.to_date,
                                     :redemption_start_date => 3.days.ago.to_date, :redemption_end_date => 2.days.ago.to_date))
      Fabricate(:user_scheme, :user => current_user,
                :scheme => Fabricate(:scheme_3x3, :start_date => 5.days.from_now.to_date, :end_date => 6.days.from_now.to_date,
                                     :redemption_start_date => 7.days.from_now.to_date, :redemption_end_date => 8.days.from_now.to_date))

      participant_dashboard.leaderboard_data.size.should == 2 # once create above and one from let

    end

    it "should return only user schemes that have current_achievements" do
      Fabricate(:user_scheme, :user => current_user, :current_achievements => nil, :scheme => Fabricate(:scheme_3x3))
      participant_dashboard.leaderboard_data.size.should == 1 # the one created in let
    end
  end

  context "Speedometer" do
    before :each do
      @user = Fabricate(:user)
      @participant_dashboard = ParticipantDashboard.new(@user)

      Timecop.freeze(2015, 10, 2)

      @ready_for_redemption_scheme = Fabricate(:scheme_3x3, :name => "Redemption Dhamaka", :start_date => Date.new(2015, 9, 1),
                                               :end_date => Date.new(2015, 9, 25),
                                               :redemption_start_date => Date.new(2015, 10, 1),
                                               :redemption_end_date => Date.new(2015, 10, 20))
      @upcoming_scheme = Fabricate(:scheme_3x3, :name => "Upcoming Dhamaka", :start_date => Date.new(2015, 10, 1),
                                   :end_date => Date.new(2015, 10, 25),
                                   :redemption_start_date => Date.new(2015, 11, 1),
                                   :redemption_end_date => Date.new(2015, 11, 20))

      @yet_another_scheme = Fabricate(:scheme_3x3, :name => "Osama Dhamaka", :start_date => Date.new(2015, 9, 1),
                                      :end_date => Date.new(2015, 9, 25),
                                      :redemption_start_date => Date.new(2015, 10, 1),
                                      :redemption_end_date => Date.new(2015, 10, 20))

      @ready_for_redemption_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @ready_for_redemption_scheme, :total_points => 50_000)
      @user_scheme_with_incomplete_targets = Fabricate(:user_scheme, :user => @user, :scheme => @yet_another_scheme)
      @upcoming_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @upcoming_scheme, :total_points => 20_000)
    end

    after :each do
      Timecop.return
    end

    it "should list user_schemes that have started and redemption has not ended and ordered by scheme start date " do
      Fabricate(:target, :start => 10_000, :club => Club.with_scheme_and_club_name(@ready_for_redemption_scheme, "silver").first, :user_scheme => @ready_for_redemption_user_scheme)
      Fabricate(:target, :start => 20_000, :club => Club.with_scheme_and_club_name(@ready_for_redemption_scheme, "gold").first, :user_scheme => @ready_for_redemption_user_scheme)
      Fabricate(:target, :start => 30_000, :club => Club.with_scheme_and_club_name(@ready_for_redemption_scheme, "platinum").first, :user_scheme => @ready_for_redemption_user_scheme)

      Fabricate(:target, :start => 10_000, :club => Club.with_scheme_and_club_name(@upcoming_scheme, "silver").first, :user_scheme => @upcoming_user_scheme)
      Fabricate(:target, :start => 20_000, :club => Club.with_scheme_and_club_name(@upcoming_scheme, "gold").first, :user_scheme => @upcoming_user_scheme)
      Fabricate(:target, :start => 30_000, :club => Club.with_scheme_and_club_name(@upcoming_scheme, "platinum").first, :user_scheme => @upcoming_user_scheme)

      Fabricate(:target, :start => nil, :club => Club.with_scheme_and_club_name(@yet_another_scheme, "silver").first, :user_scheme => @user_scheme_with_incomplete_targets)
      Fabricate(:target, :start => 20_000, :club => Club.with_scheme_and_club_name(@yet_another_scheme, "gold").first, :user_scheme => @user_scheme_with_incomplete_targets)
      Fabricate(:target, :start => 30_000, :club => Club.with_scheme_and_club_name(@yet_another_scheme, "platinum").first, :user_scheme => @user_scheme_with_incomplete_targets)

      redemption_dhamaka_json = {id: @ready_for_redemption_user_scheme.id, name: "Redemption Dhamaka", start_date: "September 1st, 2015", end_date: "October 20th, 2015",
                                 clubs: [{:name => "silver", :target_start => 10000}, {:name => "gold", :target_start => 20000}, {:name => "platinum", :target_start => 30000}],
                                 current_achievements: 20000}

      upcoming_dhamka_json = {id: @upcoming_user_scheme.id, name: "Upcoming Dhamaka", start_date: "October 1st, 2015", end_date: "November 20th, 2015",
                              clubs: [{:name => "silver", :target_start => 10000}, {:name => "gold", :target_start => 20000}, {:name => "platinum", :target_start => 30000}],
                              current_achievements: 20000}

      @participant_dashboard.speedometer_data.should == [redemption_dhamaka_json, upcoming_dhamka_json]
    end

  end
end

