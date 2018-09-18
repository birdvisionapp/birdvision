require 'spec_helper'

describe ClientManager do
  it { should allow_mass_assignment_of :client }
  it { should allow_mass_assignment_of :admin_user }
  it { should allow_mass_assignment_of :name }
  it { should allow_mass_assignment_of :mobile_number }

  it { should validate_presence_of(:name).with_message("Please enter a name") }
  it { should validate_presence_of(:email).with_message("Please enter a valid email") }
  it { should validate_numericality_of(:mobile_number).with_message("Please enter a valid 10 digit mobile number") }

  it { should validate_format_of(:mobile_number).not_with('wrong1').with_message("Please enter a valid 10 digit mobile number") }
  it { should validate_format_of(:mobile_number).with('1234567890') }

  it { should validate_format_of(:email).not_with('test').with_message("Contact email format should be valid e.g email@domain.com") }
  it { should validate_format_of(:email).with('test@test.com') }

  it { should belong_to :client}
  it { should belong_to :admin_user}
  it { should be_trailed }

  it "should create an admin_user with client_manager role" do
    client = Fabricate(:client)
    client_manager = ClientManager.create!(:name => 'some name', :email => 'client_manager@mailinator.com', :mobile_number => '1234567890', :client_id => client.id)
    client_manager.admin_user.role.should == AdminUser::Roles::CLIENT_MANAGER
    AdminUser.where(:role => AdminUser::Roles::CLIENT_MANAGER).count.should == 1
  end

  it "should sync email with an admin_user " do
    client_manager = Fabricate(:client_manager, :email => "client_manager@mailinator.com")
    client_manager.email = 'changed_email_for_client_manager@mailinator.com'
    client_manager.save!
    client_manager.reload.admin_user.email.should == 'changed_email_for_client_manager@mailinator.com'
  end

  it "should find client_manager for given admin_user" do
    client_manager = Fabricate(:client_manager)

    ClientManager.for_admin_user(client_manager.admin_user).should == client_manager
  end

  it "should find associated client for given admin_user" do
    client = Fabricate(:client)
    client_manager = Fabricate(:client_manager, :client=>client)

    ClientManager.associated_client_for(client_manager.admin_user).should == client
  end

  it "should send an account activation email" do
    client_manager = Fabricate.build(:client_manager)
    mailer = mock("mailer")
    ClientAdminUserMailer.stub(:delay).and_return mailer
    mailer.should_receive(:send_account_activation_link).with(instance_of(ClientManager)).exactly(1).times.and_return(mailer)

    client_manager.save!
  end
end
