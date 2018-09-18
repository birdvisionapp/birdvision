require 'spec_helper'

describe UserSchemeNotifier do
  let!(:mailer) { mock('mailer') }
  let!(:msg) { mock('msg') }

  context "for any given user scheme, on attribute updates" do

    let!(:user) { Fabricate(:user, :sign_in_count => 2) }
    let!(:user_scheme) { Fabricate(:user_scheme, :user => user, :total_points => 1_000, :redeemed_points => 0, :scheme => Fabricate(:scheme_3x3)) }


    it "should send email/sms for total points update" do
      updated_points = 1999

      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:user_scheme_info_update, :to => user.mobile_number, :scheme => user_scheme.scheme.name,
                                           :changes => "Total points: #{updated_points}", :client => user.client.client_name).and_return(msg)

      UserMailer.stub(:delay).and_return(mailer)
      mailer.should_receive(:account_update).with(user, user_scheme.scheme.name, hash_including(:total_points => updated_points))

      user_scheme.total_points = updated_points
      UserSchemeNotifier.notify(user_scheme)
    end

    it "should send email/sms for current achievements update" do
      updated_current_achievements = 12345

      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:user_scheme_info_update, :to => user.mobile_number, :scheme => user_scheme.scheme.name,
                                           :changes => "Current achievements: #{updated_current_achievements}", :client => user.client.client_name).and_return(msg)

      UserMailer.stub(:delay).and_return(mailer)
      mailer.should_receive(:account_update).with(user, user_scheme.scheme.name, :current_achievements => updated_current_achievements)

      user_scheme.current_achievements = updated_current_achievements
      UserSchemeNotifier.notify(user_scheme)
    end

    it "should send email/sms for club update" do
      updated_club = user_scheme.scheme.clubs.last

      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:user_scheme_info_update, :to => user.mobile_number, :scheme => user_scheme.scheme.name,
                                           :changes => "Club: #{updated_club.name}", :client => user.client.client_name).and_return(msg)
      UserMailer.stub(:delay).and_return(mailer)
      mailer.should_receive(:account_update).with(user, user_scheme.scheme.name, :club => updated_club.name)

      user_scheme.club = updated_club
      UserSchemeNotifier.notify(user_scheme)
    end

    it "should not send notifications if club is unassigned" do
      SmsMessage.should_receive(:new).never
      mailer.should_receive(:account_update).never
      user_scheme.club = nil

      UserSchemeNotifier.notify(user_scheme)
    end

    it "should not send notifications if points are unassigned" do
      SmsMessage.should_receive(:new).never
      mailer.should_receive(:account_update).never
      user_scheme.total_points = nil

      UserSchemeNotifier.notify(user_scheme)
    end

    it "should not send notifications if current_achievement are unassigned" do
      SmsMessage.should_receive(:new).never
      mailer.should_receive(:account_update).never
      user_scheme.current_achievements = nil

      UserSchemeNotifier.notify(user_scheme)
    end


    it "should send only one email/sms when any two of point, club or achievement are updated" do
      updated_points = 1999
      updated_current_achievements = 12345

      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:user_scheme_info_update, :to => user.mobile_number, :scheme => user_scheme.scheme.name,
                                           :changes => "Current achievements: #{updated_current_achievements}, Total points: #{updated_points}", :client => user.client.client_name).and_return(msg)
      UserMailer.stub(:delay).and_return(mailer)
      mailer.should_receive(:account_update).with(user, user_scheme.scheme.name, hash_including(:total_points => updated_points, :current_achievements => updated_current_achievements))

      user_scheme.total_points = updated_points
      user_scheme.current_achievements = updated_current_achievements

      UserSchemeNotifier.notify(user_scheme)
    end

    it "should send only one email/sms when all of point, club or achievement are updated" do
      updated_points = 1999
      updated_current_achievements = 12345
      updated_club = user_scheme.scheme.clubs.last

      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:user_scheme_info_update, :to => user.mobile_number, :scheme => user_scheme.scheme.name,
                                           :changes => "Current achievements: #{updated_current_achievements}, Total points: #{updated_points}, Club: #{updated_club.name}", :client => user.client.client_name).and_return(msg)
      UserMailer.stub(:delay).and_return(mailer)
      mailer.should_receive(:account_update).with(user, user_scheme.scheme.name, hash_including(:total_points => updated_points, :current_achievements => updated_current_achievements, :club => updated_club.name))

      user_scheme.total_points = updated_points
      user_scheme.current_achievements = updated_current_achievements
      user_scheme.club = updated_club
      UserSchemeNotifier.notify(user_scheme)
    end

    it "should not send email/sms if any of point, club or achievement is not changed on user_scheme's update" do
      SmsMessage.should_receive(:new).never
      mailer.should_receive(:account_update).never

      UserSchemeNotifier.notify(user_scheme)
    end
  end


  context "Single redemption scheme" do
    it "should not include points in email/sms for when a single redemption scheme's user_scheme is updated" do
      user = Fabricate(:user, :sign_in_count => 2)
      user_scheme = Fabricate(:user_scheme, :user => user, :current_achievements => 3_000, :scheme => Fabricate(:scheme_3x3, :single_redemption => true))
      update_level_club(user_scheme, 'level1', 'gold')

      updated_club = Club.with_scheme_and_club_name(user_scheme.scheme, "platinum").first
      updated_points = 1999
      updated_current_achievements = 12345

      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:user_scheme_info_update, :to => user.mobile_number, :scheme => user_scheme.scheme.name,
                                           :changes => "Current achievements: #{updated_current_achievements}, Club: #{updated_club.name}", :client => user.client.client_name).and_return(msg)
      UserMailer.stub(:delay).and_return(mailer)
      mailer.should_receive(:account_update).with(user, user_scheme.scheme.name, :current_achievements => updated_current_achievements, :club => updated_club.name)

      user_scheme.total_points = updated_points
      user_scheme.current_achievements = updated_current_achievements
      user_scheme.club = updated_club
      UserSchemeNotifier.notify(user_scheme)
    end
  end

  context "Single club scheme" do
    it "should not include club name in email/sms for when a single club scheme's user_scheme is updated" do
      user = Fabricate(:user, :sign_in_count => 2)
      user_scheme = Fabricate(:user_scheme, :user => user, :current_achievements => 3_000, :scheme => Fabricate(:scheme), :club => nil)

      updated_points = 1999
      updated_current_achievements = 12345
      updated_club = user_scheme.scheme.clubs.last

      msg.stub_chain(:delay, :deliver)
      SmsMessage.should_receive(:new).with(:user_scheme_info_update, :to => user.mobile_number, :scheme => user_scheme.scheme.name,
                                           :changes => "Current achievements: #{updated_current_achievements}, Total points: #{updated_points}", :client => user.client.client_name).and_return(msg)
      UserMailer.stub(:delay).and_return(mailer)
      mailer.should_receive(:account_update).with(user, user_scheme.scheme.name, :total_points => updated_points, :current_achievements => updated_current_achievements)

      user_scheme.total_points = updated_points
      user_scheme.current_achievements = updated_current_achievements
      user_scheme.club = updated_club
      UserSchemeNotifier.notify(user_scheme)
    end
  end

end