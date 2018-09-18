require 'spec_helper'
require "cancan/matchers"

describe AdminUser do
  it { should allow_mass_assignment_of :role }
  it { should allow_mass_assignment_of :username }
  it { should allow_mass_assignment_of :email }
  it { should allow_mass_assignment_of :password }
  it { should allow_mass_assignment_of :password_confirmation }
  it { should allow_mass_assignment_of :remember_me }
  it { should allow_mass_assignment_of :reset_password_token }
  it { should allow_mass_assignment_of :reset_password_sent_at }
  it { should have_one :reseller }
  it { should be_trailed }

  context "emails" do

    it "should send email for account activation link for super_admin" do
      admin_user = Fabricate.build(:admin_user, :password => nil, :reset_password_token => nil)
      mailer = mock("mailer")
      SuperAdminUserMailer.stub(:delay).and_return mailer
      mailer.should_receive(:send_account_activation_link).with(instance_of(AdminUser)).exactly(1).times.and_return(mailer)

      admin_user.save!

      admin_user.reset_password_token.should_not be_nil
    end

    it "should not send account activation link for any other role" do
      admin_user = Fabricate.build(:admin_user, :role => AdminUser::Roles::CLIENT_MANAGER)
      mailer = mock("mailer")
      SuperAdminUserMailer.stub(:delay).and_return mailer
      mailer.should_not_receive(:send_account_activation_link)

      admin_user.save!
    end

    it "should send confirmation email when account is activated irrespective of role" do
      user = Fabricate(:admin_user, :password => nil)

      mailer = mock("mailer")
      mailer.should_receive(:send_account_confirmation).with(instance_of(AdminUser)).exactly(1).times.and_return(mailer)
      SuperAdminUserMailer.stub(:delay).and_return mailer

      user.password = "new password"
      user.save
    end

    it "should not send an account confirmation email when user resets password second time onwards" do
      user = Fabricate(:admin_user)

      mailer = mock("mailer")
      mailer.should_not_receive(:send_account_confirmation)
      SuperAdminUserMailer.stub(:delay).and_return mailer

      user.password = "new password"
      user.save
    end
  end

  context "Passwords Validation" do
    it { should ensure_length_of(:password).is_at_least(6) }
    it { should ensure_length_of(:password).is_at_most(30).with_long_message(/.*/) }

    it { should validate_confirmation_of (:password) }

    it "should allow to save nil password while creating if no password is given" do
      admin = Fabricate.build(:admin_user, :password => nil)
      admin.save.should be_true
    end

    it "should NOT allow to save user if password is blank" do
      admin = Fabricate.build(:admin_user, :password => "")
      admin.valid?.should be_false
    end
  end
end
