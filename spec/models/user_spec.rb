require 'spec_helper'

describe User do

  it { should allow_mass_assignment_of :email }
  it { should allow_mass_assignment_of :password }
  it { should allow_mass_assignment_of :password_confirmation }
  it { should allow_mass_assignment_of :participant_id }
  it { should allow_mass_assignment_of :notes }
  it { should allow_mass_assignment_of :address }
  it { should allow_mass_assignment_of :client }
  it { should allow_mass_assignment_of :mobile_number }
  it { should allow_mass_assignment_of :username }
  it { should allow_mass_assignment_of :full_name }
  it { should allow_mass_assignment_of :pincode }
  it { should allow_mass_assignment_of :landline_number }
  it { should allow_mass_assignment_of :reset_password_token }
  it { should allow_mass_assignment_of :reset_password_sent_at }
  it { should allow_mass_assignment_of :schemes }
  it { should allow_mass_assignment_of :activation_status }
  it { should allow_mass_assignment_of :status }

  it { should have_many(:orders) }
  it { should belong_to(:client) }
  it { should have_many(:user_schemes).dependent(:destroy) }
  it { should have_many(:access_grants).dependent(:delete_all) }
  it { should have_many(:scheme_transactions) }

  it { should validate_presence_of(:participant_id) }

  it { should validate_presence_of(:mobile_number) }
  it { should validate_presence_of(:full_name) }
  #it { should validate_presence_of(:email) }
  it { should validate_presence_of(:client) }

  it { should validate_format_of(:mobile_number).not_with('wrong1').with_message("Mobile number should be numeric") }
  it { should validate_format_of(:mobile_number).with('60601').with_message("Mobile number is the wrong length (\"60601\")") }


  it { should validate_format_of(:email).not_with('test') }
  it { should validate_format_of(:email).with('test@test.com') }

  it { should validate_format_of(:participant_id).not_with('wrong1 wrong2') }
  it { should validate_format_of(:participant_id).with('right-56') }
  it { should be_trailed }


  it "should validate uniqueness for username" do
    existing_user = Fabricate(:user, :participant_id => '123')

    expect { Fabricate(:user, :participant_id => '123', :client => existing_user.client) }.to raise_error ActiveRecord::StatementInvalid
  end

  it "should return all users for a client" do
    emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
    big_bang_dhamaka = Fabricate(:scheme, :client => emerson, :name => "BBD", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today + 45.days)
    small_bang_dhamaka = Fabricate(:scheme, :client => emerson, :name => "SBD", :redemption_start_date => Date.today + 70.days, :redemption_end_date => Date.today + 90.days)
    user_scheme1 = Fabricate(:user_scheme, :scheme => big_bang_dhamaka)
    user_scheme2 = Fabricate(:user_scheme, :scheme => small_bang_dhamaka)
    user_scheme3 = Fabricate(:user_scheme, :scheme => small_bang_dhamaka)

    users = User.for_client(emerson)
    users.should include(user_scheme1.user)
    users.should include(user_scheme2.user)
    users.should include(user_scheme3.user)
    users.count.should == 3
  end

  context "activation" do
    it "should set account activation status as link not sent, on creation" do
      user = Fabricate.build(:user, :activation_status => nil)
      user.save!
      user.reload.activation_status.should == User::ActivationStatus::LINK_NOT_SENT
    end

    it "should generate reset password token and set activation status for given user id" do
      user = Fabricate(:user, :password => nil, :activation_status => User::ActivationStatus::LINK_NOT_SENT)
      user.reset_password_token.should be_nil
      User.generate_activation_token_for user.id
      user.reload.reset_password_token.should_not be_nil
      user.reset_password_sent_at.should_not be_nil
      user.activation_status.should == User::ActivationStatus::NOT_ACTIVATED
    end

    it "should not mark an active user as not activated if user activation link is sent again" do
      user = Fabricate(:user, :activation_status => User::ActivationStatus::ACTIVATED)

      User.generate_activation_token_for user.id

      user.reload.activation_status.should == User::ActivationStatus::ACTIVATED
    end
  end

  context "csv upload" do
    it "should check csv import with scheme assignment and default to points addition" do
      csv_file = stub
      csv_user = stub
      scheme = Fabricate.build(:scheme_3x3)
      Scheme.should_receive(:find).with(scheme.id).and_return(scheme)
      CsvUser.should_receive(:new).with(scheme, true).and_return(csv_user)
      User.should_receive(:import_from_file).with(csv_file, csv_user)
      User.create_many_from_csv(csv_file, scheme.id, {:add_points => true})
    end

    it "should check csv import with scheme assignment and replace points" do
      csv_file = stub
      csv_user = stub
      scheme = Fabricate.build(:scheme_3x3)
      Scheme.should_receive(:find).with(scheme.id).and_return(scheme)
      CsvUser.should_receive(:new).with(scheme, false).and_return(csv_user)
      User.should_receive(:import_from_file).with(csv_file, csv_user)
      User.create_many_from_csv(csv_file, scheme.id, {:add_points => false})
    end
  end

  context "Passwords Validation" do
    it { should ensure_length_of(:password).is_at_least(6) }
    it { should ensure_length_of(:password).is_at_most(30).with_long_message(/.*/) }

    it { should validate_confirmation_of (:password) }

    it "should allow to save nil password while creating if no password is given" do
      user = Fabricate.build(:user, :password => nil)
      user.save.should be_true
    end

    it "should NOT allow to save user if password is blank" do
      user = Fabricate.build(:user, :password => "")
      user.valid?.should be_false
    end
  end

  context "Hooks" do
    it "should generate username from client name and participant id and convert it to downcase" do
      client = Fabricate(:client, :client_name => 'Acme Inc')
      user = Fabricate.build(:user, :participant_id => "123", :client => client)
      user.username.should be_empty
      user.save
      user.username.should == "acme-inc.123"
    end

    it "should send notification when the password is set for the first time and set status to activated" do
      user = Fabricate(:user, :password => nil)
      user.password = "new password"
      UserNotifier.should_receive(:notify_activation_complete).with(user)

      Timecop.freeze do
        user.save

        user.reload.activation_status.should == User::ActivationStatus::ACTIVATED
        user.activated_at.to_date.should == Time.now.to_date
      end
    end
  end

  context "point based" do

    context "points" do

      it "should return total redeemable points for a user" do
        emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
        active_scheme = Fabricate(:scheme, :client => emerson, :name => "BBD", :redemption_start_date => Date.today, :redemption_end_date => Date.today + 45.days)
        past_scheme = Fabricate(:expired_scheme, :client => emerson, :name => "SBD")
        user = Fabricate(:user, :participant_id => "U1", :client => emerson)
        Fabricate(:user_scheme, :user => user, :scheme => active_scheme, :total_points => 10_00_000, :redeemed_points => 2_00_000)
        Fabricate(:user_scheme, :user => user, :scheme => past_scheme, :total_points => 10_00_000, :redeemed_points => 4_00_000)
        Fabricate(:single_redemption_user_scheme, :user => user, :total_points => 300)
        user.total_redeemable_points.should == 14_00_000
      end

      it "should return total redeemed points for a user" do
        emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
        active_scheme = Fabricate(:scheme, :client => emerson, :name => "BBD", :redemption_start_date => Date.today, :redemption_end_date => Date.today + 45.days)
        past_scheme = Fabricate(:expired_scheme, :client => emerson, :name => "SBD")
        user = Fabricate(:user, :participant_id => "U1", :client => emerson)
        Fabricate(:user_scheme, :user => user, :scheme => active_scheme, :total_points => 10_00_000, :redeemed_points => 2_00_000)
        Fabricate(:user_scheme, :user => user, :scheme => past_scheme, :total_points => 10_00_000, :redeemed_points => 4_00_000)
        Fabricate(:single_redemption_user_scheme, :user => user, :total_points => 300)
        user.total_redeemed_points.should == 6_00_000
      end

      it "should return total points for a user for all active and past schemes" do
        emerson = Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2)
        active_scheme = Fabricate(:scheme, :client => emerson, :name => "BBD", :redemption_start_date => Date.today, :redemption_end_date => Date.today + 45.days)
        past_scheme = Fabricate(:expired_scheme, :client => emerson, :name => "SBD")
        user = Fabricate(:user, :participant_id => "U1", :client => emerson)
        Fabricate(:user_scheme, :user => user, :scheme => active_scheme, :total_points => 10_00_000)
        Fabricate(:user_scheme, :user => user, :scheme => past_scheme, :total_points => 20_00_000)
        Fabricate(:user_scheme, :user => user, :scheme => past_scheme, :total_points => 0)
        Fabricate(:single_redemption_user_scheme, :user => user, :total_points => 300)
        user.total_points_for_past_and_active_schemes.should == 30_00_000
      end
    end
  end

  context "single redemption" do
    it "should tell if user has sufficient points to redeem cart" do
      user = Fabricate(:user)
      Fabricate(:single_redemption_user_scheme, :user => user)

      user.user_schemes.first.has_sufficient_points?.should be_true
    end
  end
end