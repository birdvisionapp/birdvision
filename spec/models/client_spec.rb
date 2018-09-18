require "spec_helper"

describe Client do
  it { should allow_mass_assignment_of :client_name }
  it { should allow_mass_assignment_of :contact_name }
  it { should allow_mass_assignment_of :contact_phone_number }
  it { should allow_mass_assignment_of :contact_email }
  it { should allow_mass_assignment_of :points_to_rupee_ratio }
  it { should allow_mass_assignment_of :description }
  it { should allow_mass_assignment_of :notes }
  it { should allow_mass_assignment_of :domain_name }
  it { should allow_mass_assignment_of :reseller_ids }
  it { should allow_mass_assignment_of :custom_theme }
  it { should allow_mass_assignment_of :code }
  it { should allow_mass_assignment_of :client_url }
  it { should allow_mass_assignment_of :allow_sso }
  it { should_not allow_mass_assignment_of :client_key }
  it { should_not allow_mass_assignment_of :client_secret }
  it { should allow_mass_assignment_of :allow_otp }
  it { should allow_mass_assignment_of :allow_otp_email }
  it { should allow_mass_assignment_of :allow_otp_mobile }
  it { should allow_mass_assignment_of :otp_code_expiration }

  it { should have_attached_file(:custom_theme) }
  it { should validate_attachment_content_type(:custom_theme).allowing('text/plain', 'text/css').rejecting('text/csv', 'image/jpeg') }

  it { should have_many(:client_resellers) }
  it { should have_many(:resellers).through(:client_resellers) }
  it { should have_many(:access_grants).dependent(:delete_all) }

  it { should validate_presence_of(:client_name) }

  it { should validate_presence_of(:code) }
  it { should validate_format_of(:code).with("acme_inc") }
  it { should validate_format_of(:code).not_with("acme inc") }

  it { should validate_numericality_of :contact_phone_number }
  it { should validate_numericality_of :points_to_rupee_ratio }

  it { should validate_format_of(:contact_email).not_with('aabb ') }
  it { should validate_format_of(:contact_email).with('right@email.com') }

  it { should validate_uniqueness_of(:client_key) }
  it { should validate_uniqueness_of(:client_secret) }

  it { should belong_to(:client_catalog) }
  it { should have_many(:schemes) }
  it { should have_many(:client_managers) }
  it { should have_many(:scheme_transactions) }

  it { should be_trailed }

  it "should validate uniqueness of client_name" do
    acme_client = Fabricate(:client, :client_name => 'Acme')

    duplicate = Fabricate.build(:client, :client_name => 'Acme')
    duplicate.valid?.should be_false
    duplicate.errors.first.should == [:client_name, "The Client name is already in use. Please enter another title"]
  end

  it "should validate uniqueness of code" do
    acme_client = Fabricate(:client, :code => "random-code")

    duplicate = Fabricate.build(:client, :code => "random-code")
    duplicate.valid?.should be_false
    duplicate.errors.first.should == [:code, "The code is already in use. Please enter another code"]
  end

  it "should validate presence of domain_name if custom theme is specified" do
    acme_client = Fabricate.build(:client, :domain_name => nil, :custom_theme => File.new("#{Rails.root}/spec/fixtures/custom_theme_1.css"))

    acme_client.valid?.should be_false
    acme_client.errors.first.should == [:domain_name, "Please specify a subdomain for which the custom theme should be applied"]
  end

  it "should add item to client catalog" do
    client = Fabricate(:client)
    item1 = Fabricate(:item)
    item2 = Fabricate(:item)
    client.add_to_catalog([item1.id, item2.id])
    client.client_items.count.should == 2
  end

  it "should create a client catalog for a client" do
    client = Fabricate(:client, :client_catalog => nil)

    client.client_catalog.should_not be_nil
  end

  it "should skip items if already in client items" do
    client = Fabricate(:client)
    item1 = Fabricate(:item)
    client.add_to_catalog([item1, item1])
    client.client_items.count.should == 1
  end

  it "should activate the item if it was already soft deleted and now being added" do

    client = Fabricate(:client)
    client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => true)
    client.add_to_catalog [client_item1.item]
    client.client_items.count.should == 2
    client.client_items.first.deleted.should == true
    client.client_items.last.deleted.should == false
  end

  it "should return clients associated to a reseller" do
    reseller = Fabricate(:reseller)
    client = Fabricate(:client)
    Fabricate(:client_reseller, :client => client, :reseller => reseller)

    Client.for_reseller(reseller).should == [client]
  end
  
  it "should authenticate client for given client_key and client_secret" do
    client = Fabricate(:client_allow_sso)
    Client.authenticate(client.client_key, client.client_secret).should == client
  end

  it "should fail to append client_key and client_secret before save if allow_sso not checked" do
    client = Fabricate(:client, :allow_sso => false)
    client.client_key.should be_nil
    client.client_secret.should be_nil
  end

  it "should append client_key and client_secret before create or save" do
    client = Fabricate(:client_allow_sso)
    client.client_key.should_not be_nil
    client.client_secret.should_not be_nil
  end

  it "should validate presence of client_url if allow_sso checked" do
    acme_client = Fabricate.build(:client_allow_sso, :client_url => nil)

    acme_client.valid?.should be_false
    acme_client.errors.first.should == [:client_url, "Please enter a client url"]
  end

  it "should validate format of client_url if allow_sso checked" do
    acme_client = Fabricate.build(:client_allow_sso, :client_url => 'testdomain')

    acme_client.valid?.should be_false
    acme_client.errors.first.should == [:client_url, "Client url format should be valid e.g domain.com"]
  end

  it "should validate selection of otp sending option if allow_otp checked" do
    client = Fabricate.build(:client_allow_otp, :allow_otp_email => false, :allow_otp_mobile => false)
    client.valid?.should be_false
    client.errors.first.should == [:allow_otp, "Please select atleast one OTP sending option"]
  end


  it "should validate otp code expiration time if allow_otp checked" do
    client = Fabricate.build(:client_allow_otp, :otp_code_expiration => nil)
    client.valid?.should be_false
    client.errors.first.should == [:otp_code_expiration, "Please enter the OTP expiration time"]
  end

  it "should validate otp code expiration time with valid format" do
    client = Fabricate.build(:client_allow_otp, :otp_code_expiration => 't1000')
    client.valid?.should be_false
    client.errors.first.should == [:otp_code_expiration, "The OTP expiration time should be numeric"]
  end

  it "should validate uniqueness of domain_name" do
    client = Fabricate(:client, :domain_name => 'domain.test.com', :custom_theme => File.new("#{Rails.root}/spec/fixtures/custom_theme_1.css"))
    duplicate = Fabricate.build(:client, :domain_name => 'domain.test.com', :custom_theme => File.new("#{Rails.root}/spec/fixtures/custom_theme_1.css"))
    duplicate.valid?.should be_false
    duplicate.errors.first.should == [:domain_name, "The subdomain already in use. Please enter another subdomain"]
  end
  
end

