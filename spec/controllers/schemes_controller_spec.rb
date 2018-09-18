require 'spec_helper'

describe SchemesController do
  context "routes" do
    it "should route requests correctly" do
      {:get => schemes_path}.should route_to('schemes#index')
      {:get => participant_speedometer_path}.should route_to("schemes#participant_speedometer")
      {:get => participant_leaderboard_path}.should route_to("schemes#participant_leaderboard")
    end
  end

  it "should redirect user to signin page given anonymous user" do
    get :index
    response.should redirect_to(new_user_session_path)
  end

  context "dashboard" do
    login_user

    it "should show dashboard if achievements are presents for at least one scheme" do
      Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme), :current_achievements => 100)

      get :index

      assigns[:show_dashboard].should == true
    end

    it "should not show dashboard if achievements are not presents any scheme" do
      Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme), :current_achievements => nil)

      get :index

      assigns[:show_dashboard].should == false
    end

    it "should show leaderboard for user_schemes that have started and redemption has not ended and ordered by scheme start date " do
      mock = mock("ParticipantDashboard")
      mock.should_receive(:leaderboard_data).and_return({id: "LeaderboardData"})

      ParticipantDashboard.should_receive(:new).with(@user).and_return(mock)

      get :participant_leaderboard

      response.body.should include("LeaderboardData")
    end

    it "should show speedometer for browsable schemes" do
      mock = mock("ParticipantDashboard")
      mock.should_receive(:speedometer_data).and_return({id: "SpeedometerData"})

      ParticipantDashboard.should_receive(:new).with(@user).and_return(mock)

      get :participant_speedometer

      response.body.should include("SpeedometerData")
    end
  end

  context "point based landing page" do
    login_user

    before :each do
      Timecop.freeze(2015, 10, 2)
      @ready_for_redemption_scheme = Fabricate(:scheme_3x3, :name => "Redemption Dhamaka", :start_date => Date.new(2015, 9, 1),
                                               :end_date => Date.new(2015, 9, 25),
                                               :redemption_start_date => Date.new(2015, 10, 1),
                                               :redemption_end_date => Date.new(2015, 10, 20))
      @upcoming_scheme = Fabricate(:scheme_3x3, :name => "Upcoming Dhamaka", :start_date => Date.new(2015, 10, 1),
                                   :end_date => Date.new(2015, 10, 25),
                                   :redemption_start_date => Date.new(2015, 11, 1),
                                   :redemption_end_date => Date.new(2015, 11, 20))
      @past_scheme = Fabricate(:scheme_3x3, :name => "Past Dhamaka", :start_date => Date.new(2015, 8, 1),
                               :end_date => Date.new(2015, 8, 25),
                               :redemption_start_date => Date.new(2015, 9, 1),
                               :redemption_end_date => Date.new(2015, 9, 20))
      @scheme_not_yet_started = Fabricate(:scheme_3x3, :name => "Not started Dhamaka", :start_date => Date.new(2016, 8, 1),
                                          :end_date => Date.new(2016, 8, 25),
                                          :redemption_start_date => Date.new(2016, 9, 1),
                                          :redemption_end_date => Date.new(2016, 9, 20))
      @yet_another_scheme = Fabricate(:scheme_3x3, :name => "Osama Dhamaka", :start_date => Date.new(2015, 9, 1),
                                      :end_date => Date.new(2015, 9, 25),
                                      :redemption_start_date => Date.new(2015, 10, 1),
                                      :redemption_end_date => Date.new(2015, 10, 20))

      @ready_for_redemption_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @ready_for_redemption_scheme, :total_points => 50_000)
      @user_scheme_with_incomplete_targets = Fabricate(:user_scheme, :user => @user, :scheme => @yet_another_scheme)
      @upcoming_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @upcoming_scheme, :total_points => 20_000)
      @past_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => @past_scheme, :total_points => 10_000)
      Fabricate(:user_scheme, :user => @user, :scheme => @scheme_not_yet_started, :total_points => 10_000)
    end

    after :each do
      Timecop.return
    end

    it "should show active participant schemes" do
      get :index

      active_scheme = assigns[:schemes][:ready_for_redemption].first
      active_scheme.scheme.should == @ready_for_redemption_scheme
      active_scheme.user_scheme.should == @ready_for_redemption_user_scheme
      active_scheme.message.should == "You can redeem these rewards until October 20th, 2015"
      active_scheme.button_text.should == "Redeem Rewards"
      active_scheme.can_proceed.should == true
      active_scheme.points_text.should == "50,000 points earned"
    end

    it "should show schemes which have already started" do
      get :index

      assigns[:hide_search].should == true

      future_scheme = assigns[:schemes][:upcoming].first
      future_scheme.scheme.should == @upcoming_scheme
      future_scheme.user_scheme.should == @upcoming_user_scheme
      future_scheme.message.should == "You can redeem these rewards from November 1st, 2015"
      future_scheme.button_text.should == "View Rewards"
      future_scheme.can_proceed.should == true
      future_scheme.points_text.should include("20,000")
    end

    it "should show schemes which have completed the redemption period" do

      get :index

      expired_scheme = assigns[:schemes][:past].first
      expired_scheme.scheme.should == @past_scheme
      expired_scheme.user_scheme.should == @past_user_scheme
      expired_scheme.message.should == "The Redemption period for this scheme is over"
      expired_scheme.button_text.should == ""
      expired_scheme.can_proceed.should == false
      expired_scheme.points_text.should include("10,000")
    end
  end

  context "single-redemption" do
    login_user

    it "should not show scheme points for single redemption schemes" do
      Fabricate(:user_scheme, :scheme => Fabricate(:scheme, :single_redemption => true), :user => @user)

      get :index

      scheme = assigns[:schemes][:ready_for_redemption].first
      scheme.points_text.should be_nil
    end
  end
end

