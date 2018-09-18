require 'spec_helper'

describe Reseller do
  it { should allow_mass_assignment_of :name }
  it { should allow_mass_assignment_of :phone_number }
  it { should allow_mass_assignment_of :email }

  it { should have_many(:client_resellers) }

  it { should belong_to(:admin_user) }

  it { should validate_presence_of(:name).with_message("Please enter a name") }
  it { should validate_presence_of(:email).with_message("Please enter a valid email") }
  it { should validate_numericality_of(:phone_number).with_message("Please enter a valid 10 digit mobile/phone number") }

  it { should validate_format_of(:phone_number).not_with('wrong1').with_message("Please enter a valid 10 digit mobile/phone number") }
  it { should validate_format_of(:phone_number).with('1234567890') }

  it { should validate_format_of(:email).not_with('test').with_message("Contact email format should be valid e.g email@domain.com") }
  it { should validate_format_of(:email).with('test@test.com') }
  it { should be_trailed }

  it "should return only active client resellers for a reseller" do
    client_reseller = Fabricate(:client_reseller)
    reseller = client_reseller.reseller
    Fabricate(:client_reseller, :reseller => reseller, :assigned => false)
    reseller.assigned_client_resellers.should == [client_reseller]
  end

  context "after Create" do
    it "should create an admin user for a reseller" do
      reseller = Fabricate.build(:reseller)
      reseller.admin_user.should == nil
      reseller.save!
      admin_user = reseller.reload.admin_user
      admin_user.should_not == nil
      admin_user.username.should == "bvc.#{reseller.id}"
      admin_user.role.should == AdminUser::Roles::RESELLER
    end

    it "should send an account activation email" do
      reseller = Fabricate.build(:reseller)
      mailer = mock("mailer")
      ClientAdminUserMailer.stub(:delay).and_return mailer
      mailer.should_receive(:send_account_activation_link).with(instance_of(Reseller)).exactly(1).times.and_return(mailer)

      reseller.save!
    end
  end


  context "Payout" do
    it "should calculate total payout for a reseller" do
      reseller = Fabricate(:reseller, :admin_user => @admin)

      emerson = Fabricate(:client, :client_name => "emerson")
      client_reseller1 = Fabricate(:client_reseller, :client => emerson, :reseller => reseller)
      Fabricate(:slab, :payout_percentage => 10, :lower_limit => 800, :client_reseller => client_reseller1)

      axis = Fabricate(:client, :client_name => "axis")
      client_reseller2 = Fabricate(:client_reseller, :client => axis, :reseller => reseller)
      Fabricate(:slab, :payout_percentage => 20, :lower_limit => 1500, :client_reseller => client_reseller2)

      bbd = Fabricate(:scheme, :name => "bbd", :client => emerson)
      sbd = Fabricate(:scheme, :single_redemption => true, :name => "sbd", :client => axis)
      Fabricate(:order_item, :scheme => bbd, :price_in_rupees => 1_000)
      Fabricate(:order_item, :scheme => sbd, :price_in_rupees => 2_000)
      reseller.payout_total.should == 500
    end
  end

  it "should show orders total for a reseller" do
    reseller = Fabricate(:reseller, :admin_user => @admin)

    emerson = Fabricate(:client, :client_name => "emerson")
    Fabricate(:client_reseller, :client => emerson, :reseller => reseller, :payout_start_date => Date.today)

    trend_micro = Fabricate(:client, :client_name => "trend micro")
    Fabricate(:client_reseller, :client => trend_micro, :reseller => reseller, :payout_start_date => Date.tomorrow)

    axis = Fabricate(:client, :client_name => "axis")
    Fabricate(:client_reseller, :client => axis, :reseller => reseller, :payout_start_date => Date.today)

    bbd = Fabricate(:scheme, :name => "bbd", :client => emerson)
    sbd = Fabricate(:scheme, :single_redemption => true, :name => "sbd", :client => axis)
    vsbd = Fabricate(:scheme, :single_redemption => true, :name => "vsbd", :client => trend_micro)

    Fabricate(:order_item, :scheme => bbd, :price_in_rupees => 1_000)
    Fabricate(:order_item, :scheme => sbd, :price_in_rupees => 2_000)
    Fabricate(:order_item, :scheme => vsbd, :price_in_rupees => 3_000)
    reseller.sales_total.should == 3_000
  end

  context "soft delete" do
    it "should unassign reseller from a client" do
      client_reseller = Fabricate(:client_reseller)
      reseller = client_reseller.reseller
      client = client_reseller.client
      reseller.unassign(client)
      reseller.client_resellers.first.reload.assigned.should == false
      reseller.client_resellers.first.reload.payout_end_date.should == Date.today
      reseller.assigned_client_resellers.should_not include(client_reseller)
    end
  end
end