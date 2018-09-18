require 'spec_helper'

describe ClientReseller do
  it { should allow_mass_assignment_of :payout_start_date }
  it { should allow_mass_assignment_of :finders_fee }

  it { should allow_mass_assignment_of :client_id }
  it { should allow_mass_assignment_of :reseller_id }
  it { should allow_mass_assignment_of :assigned }

  it { should allow_mass_assignment_of :payout_end_date }

  it { should belong_to :client }
  it { should belong_to :reseller }
  it { should have_many :slabs }
  it { should accept_nested_attributes_for(:slabs) }

  it { should validate_presence_of(:payout_start_date).with_message("Please enter payout start date") }
  it { should validate_presence_of(:finders_fee).with_message("Please enter finders fee") }
  it { should validate_presence_of(:reseller_id) }
  it { should validate_presence_of(:client_id).with_message("Please select a client") }

  it { should validate_numericality_of(:finders_fee) }
  it { should be_trailed }

  context "uniqueness" do
    #TODO - Shoulda not working for uniqueness - Geet/Rahul
    it "should validate uniqueness of client" do
      client = Fabricate(:client)
      reseller = Fabricate(:reseller)
      Fabricate(:client_reseller, :reseller => reseller, :client => client)
      client_reseller = ClientReseller.new(:client_id => client.id, :reseller_id => reseller.id)
      client_reseller.should have(1).error_on(:client_id)
      client_reseller.errors.first.should == [:client_id, "Selected client already has a reseller assigned."]

    end

    it "should not allow a client with more than one reseller" do
      client = Fabricate(:client)
      reseller = Fabricate(:reseller)
      reseller2 = Fabricate(:reseller)
      Fabricate(:client_reseller, :reseller => reseller, :client => client)
      client_reseller = ClientReseller.new(:client_id => client.id, :reseller_id => reseller2.id)
      client_reseller.should have(1).error_on(:client_id)
      client_reseller.errors.first.should == [:client_id, "Selected client already has a reseller assigned."]
    end

    it "should not allow a reassigneing same reseller to a client" do
      client = Fabricate(:client)
      reseller = Fabricate(:reseller)
      Fabricate(:client_reseller, :reseller => reseller, :client => client, :assigned => false)
      client_reseller = ClientReseller.new(:client_id => client.id, :reseller_id => reseller.id)
      client_reseller.should have(1).error_on(:client_id)
      client_reseller.errors.first.should == [:client_id, "You can not reassign a client to the reseller"]
    end
  end

  context "payout" do

    let(:client_reseller) { Fabricate(:client_reseller) }
    let(:scheme) { Fabricate(:scheme, :client => client_reseller.client) }

    it "should return payout for a reseller if sales are above the highest slab limit" do
      Fabricate(:slab, :payout_percentage => 10, :lower_limit => 15_000, :client_reseller => client_reseller)
      Fabricate(:slab, :payout_percentage => 12, :lower_limit => 20_000, :client_reseller => client_reseller)
      slab3 = Fabricate(:slab, :payout_percentage => 15, :lower_limit => 25_000, :client_reseller => client_reseller)

      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000)
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 16_000)
      client_reseller.payout.should == (slab3.payout_percentage/100) * 26_000
    end

    it "should return 0 payout for a reseller if sales are below any slab limit" do
      Fabricate(:slab, :payout_percentage => 10, :lower_limit => 15_000, :client_reseller => client_reseller)
      Fabricate(:slab, :payout_percentage => 12, :lower_limit => 20_000, :client_reseller => client_reseller)
      Fabricate(:slab, :payout_percentage => 15, :lower_limit => 25_000, :client_reseller => client_reseller)

      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 100)
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 160)
      client_reseller.payout.should == 0
    end

    it "should return payout for a reseller if sales are in between any two slabs limit" do
      Fabricate(:slab, :payout_percentage => 10, :lower_limit => 15_000, :client_reseller => client_reseller)
      slab = Fabricate(:slab, :payout_percentage => 12, :lower_limit => 20_000, :client_reseller => client_reseller)
      Fabricate(:slab, :payout_percentage => 15, :lower_limit => 25_000, :client_reseller => client_reseller)

      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000)
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000)
      client_reseller.payout.should == (slab.payout_percentage/100) * 20_000
    end
  end

  context "sales" do

    let(:client_reseller) { Fabricate(:client_reseller) }
    let(:scheme) { Fabricate(:scheme, :client => client_reseller.client) }

    it "should return client sales total for orders placed between payout start date and end date" do
      client_reseller.update_attributes(:payout_start_date => Date.yesterday-1, :payout_end_date => Date.today)

      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000, :created_at => Date.today - 3.days)
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 30_000, :created_at => Date.yesterday)
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 20_000, :created_at => Date.today)
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 50_000, :created_at => Date.tomorrow)

      client_reseller.sales.should == 50_000
    end

    it "should return payout for orders between payout start date and today's EOD if payout end date is not given" do
      client_reseller.update_attributes(:payout_start_date => Date.yesterday)
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000, :created_at => Date.tomorrow)
      order_item_in_range = Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000, :created_at => Date.today)
      client_reseller.order_items_in_payout_range.should == [order_item_in_range]
      client_reseller.sales.should == 10_000
    end

    it "should include only valid orders" do
      client_reseller.update_attributes(:payout_start_date => Date.yesterday)
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000, :created_at => Date.today, :status=>"incorrect")
      Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000, :created_at => Date.today)
      client_reseller.sales.should == 10_000
    end
  end
end
