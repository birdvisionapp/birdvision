require 'spec_helper'

describe Scheme do
  it { should allow_mass_assignment_of :client_id }
  it { should allow_mass_assignment_of :name }
  it { should allow_mass_assignment_of :start_date }
  it { should allow_mass_assignment_of :end_date }
  it { should allow_mass_assignment_of :redemption_start_date }
  it { should allow_mass_assignment_of :redemption_end_date }
  it { should allow_mass_assignment_of :poster }
  it { should allow_mass_assignment_of :hero_image }
  it { should allow_mass_assignment_of :total_budget_in_rupees }
  it { should allow_mass_assignment_of :single_redemption }

  it { should_not allow_mass_assignment_of :slug }

  it { should validate_presence_of :name }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :redemption_end_date }
  it { should validate_presence_of :redemption_start_date }
  it { should validate_numericality_of(:total_budget_in_rupees) }

  it { should belong_to(:client) }
  it { should have_many(:level_clubs) }
  it { should have_many(:catalog_items) }
  it { should have_many(:client_items) }
  it { should have_many(:levels).through(:level_clubs) }
  it { should have_many(:clubs).through(:level_clubs) }
  it { should have_attached_file(:poster) }
  it { should have_attached_file(:hero_image) }

  it { should have_many(:user_schemes) }
  it { should have_many(:scheme_transactions) }

  it { should be_trailed }

  it "should add slug to scheme before saving" do
    scheme = Fabricate(:scheme, :name => 'very very small dhamaka')
    scheme.slug.should == 'very-very-small-dhamaka'
  end
  it " should validate_presence_of name " do
    client = Fabricate(:client)
    Fabricate(:scheme, :name => 'Scheme1', :client => client)
    expect {
      Fabricate(:scheme, :name => 'Scheme1', :client => client).should have(1).error_on(:name)
    }.to raise_error ActiveRecord::RecordInvalid

  end
  it " should validate_presence_of client " do
    Scheme.new(:start_date => Date.today, :end_date => Date.today - 2.days).should have(1).error_on(:client)
  end


  it "should validate uniqueness of scheme name for the same client" do
    client = Fabricate(:client)
    scheme1 = Fabricate(:scheme, :name => 'Scheme1', :client => client)

    expect {
      Fabricate(:scheme, :name => 'Scheme1', :client => client)
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it "should validate redemption date of scheme same client" do
    client = Fabricate(:client)
    expect {
      Fabricate(:scheme, :name => 'Scheme2',
        :client => client,
        :start_date => Date.today,
        :end_date => Date.today + 2.days,
        :redemption_start_date => Date.today - 4.days,
        :redemption_end_date => Date.today + 5.days
      )
    }.to raise_error ActiveRecord::RecordInvalid
    expect {
      Fabricate(:scheme, :name => 'Scheme2',
        :client => client,
        :start_date => Date.today,
        :end_date => Date.today + 2.days
      )
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it "should return true if points should be shown for a participant" do
    scheme = Fabricate(:scheme, :single_redemption => false)
    scheme.show_points?.should == true
  end

  it "should return false if points should not be shown for a participant" do
    scheme = Fabricate(:scheme, :single_redemption => true)
    scheme.show_points?.should == false
  end

  it "should return true if scheme is 1x1" do
    scheme = Fabricate(:scheme)
    scheme.is_1x1?.should == true
  end

  it "should return false if scheme is not 1x1" do
    scheme_3x3 = Fabricate(:scheme_3x3)
    scheme_3x3.is_1x1?.should == false
  end

  context "level, club uniqueness" do
    it "should validate uniqueness of level, club names for a scheme" do
      scheme = Fabricate.build(:scheme, :levels => %w(l1 l1), :clubs => %w(gold))
      scheme.valid?.should be_false
      scheme.errors.full_messages.should == ["Level names need to be unique"]
    end

    it "should ignore case, spaces" do
      scheme = Fabricate.build(:scheme, :levels => ["  l1 ", "l1"], :clubs => ["gold", "Gold "])
      scheme.valid?.should be_false
      scheme.errors.full_messages.should == ["Level names need to be unique", "Club names need to be unique"]
    end
  end

  context "duration" do
    before :each do
      @client = Fabricate(:client)
    end
    it "should have scheme start date before scheme end date" do
      Scheme.new(:client_id => @client.id, :start_date => Date.today, :end_date => Date.today - 2.days).should have(1).error_on(:start_date)
    end
    it "should have scheme redemption start date before scheme redemption end date" do
      Scheme.new(:client_id => @client.id, :redemption_start_date => Date.today, :redemption_end_date => Date.today - 2.days).should have(1).error_on(:redemption_start_date)
    end
    it "should have scheme redemption start date after scheme start date" do
      Scheme.new(:client_id => @client.id, :start_date => Date.tomorrow, :end_date => Date.today + 1.month, :redemption_start_date => Date.today, :redemption_end_date => nil).should have(1).error_on(:start_date)
    end
  end

  it "should return scheme phase" do
    client = Fabricate(:client)
    Scheme.new(:client_id => client.id, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.tomorrow).phase.should == "Ready For Redemption"
    Scheme.new(:client_id => client.id, :redemption_start_date => Date.tomorrow, :redemption_end_date => Date.tomorrow + 10.days).phase.should == "Upcoming"
    Scheme.new(:client_id => client.id, :redemption_start_date => Date.tomorrow, :redemption_end_date => Date.today + 90.days).phase.should == "Upcoming"
    Scheme.new(:client_id => client.id, :redemption_start_date => Date.today - 4.days, :redemption_end_date => Date.today - 2.days).phase.should == "Past"
    Scheme.new(:client_id => client.id, :start_date => Date.today + 2.days, :end_date => Date.today + 9.days, :redemption_start_date => Date.today + 14.days, :redemption_end_date => Date.today + 20.days).phase.should == "Upcoming"
    Scheme.new(:client_id => client.id, :start_date => Date.today - 15.days, :end_date => Date.today + 9.days, :redemption_start_date => Date.today + 4.days, :redemption_end_date => Date.today + 8.days).phase.should == "Upcoming"
  end

  context "redemption active" do
    before :each do
      @client = Fabricate(:client)
    end
    it "should return true if current date is between scheme redemption period" do
      Scheme.new(:client_id => @client.id, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.tomorrow).redemption_active?.should be_true
    end
    it "should return false if redemption start date is in the future" do
      Scheme.new(:client_id => @client.id, :redemption_start_date => Date.tomorrow, :redemption_end_date => nil).redemption_active?.should be_false
    end
    it "should return true if redemption date is over" do
      Scheme.new(:client_id => @client.id, :redemption_start_date => Date.today - 4.days, :redemption_end_date => Date.today - 2.days).redemption_over?.should be_true
    end

    context "browsable" do
      it "should return false if redemption date is over" do
        Scheme.new(:client_id => @client.id, :redemption_start_date => Date.today - 4.days, :redemption_end_date => Date.today - 2.days).browsable?.should be_false
      end
      it "should return false if scheme is not yet started" do
        Scheme.new(:client_id => @client.id, :start_date => Date.today + 2.days, :end_date => Date.today + 9.days, :redemption_start_date => Date.today + 14.days, :redemption_end_date => Date.today + 20.days).browsable?.should be_false
      end
      it "should return true if scheme starts today" do
        Scheme.new(:client_id => @client.id, :start_date => Date.today, :end_date => Date.today + 9.days, :redemption_start_date => Date.today + 14.days, :redemption_end_date => Date.today + 20.days).browsable?.should be_true
      end
      it "should return false if redemption date is not over" do
        Scheme.new(:client_id => @client.id, :redemption_start_date => Date.today - 4.days, :redemption_end_date => Date.today + 2.days).redemption_over?.should be_false
      end
      it "should return true if redemption date is not over" do
        Scheme.new(:client_id => @client.id, :start_date => Date.today - 15.days, :end_date => Date.today + 9.days, :redemption_start_date => Date.today - 4.days, :redemption_end_date => Date.today + 2.days).browsable?.should be_true
      end
    end

    it "should return false if redemption date is not over" do
      Scheme.new(:client_id => @client.id, :redemption_start_date => Date.today + 1.days, :redemption_end_date => Date.today + 3.days).redemption_over?.should be_false
    end

    it "should return false if redemption date is not over" do
      Scheme.new(:client_id => @client.id, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today).redemption_over?.should be_false
    end

  end

  it "should return display name with client name" do
    Fabricate.build(:scheme, :name => 'Dhamaka', :client => Fabricate(:client, :client_name => 'Acme')).display_name.should == 'Acme - Dhamaka'
  end

  context "catalog" do
    it "should create catalogs for given levels and clubs" do
      client = Fabricate(:client)

      scheme = Fabricate.build(:scheme, :client => client)
      scheme.level_clubs = []
      scheme.create_level_clubs(%w(level1 level2), %w(platinum gold))

      scheme.catalogs.count.should == 4
      scheme.catalogs.collect(&:name).should include("Level1-Platinum", "Level1-Gold", "Level2-Platinum", "Level2-Gold")
    end

    it "should add catalog item" do
      client = Fabricate(:client)
      scheme = Fabricate(:scheme, :client => client)
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)

      scheme.catalog.add([client_item1])
      scheme.reload.catalog_items.size.should == 1
    end

    it "should not add the same catalog item twice" do
      client = Fabricate(:client)
      scheme = Fabricate(:scheme, :client => client)
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)

      scheme.catalog.add([client_item1])
      scheme.catalog.add([client_item1])
      scheme.reload.catalog_items.size.should == 1
    end

    it "should remove catalog item and related level clubs" do
      client = Fabricate(:client)
      scheme = Fabricate(:scheme, :levels => %w(level1), :clubs => %w(platinum gold), :client => client)
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog)
      scheme.reload.catalog.add([client_item1])

      scheme.level_clubs.first.catalog.add [client_item1]
      scheme.reload.level_clubs.first.catalog.size.should == 1

      scheme.level_clubs.second.catalog.add [client_item1]
      scheme.reload.level_clubs.second.catalog.size.should == 1

      scheme.remove(client_item1)
      scheme.reload.catalog_items.size.should == 0
      scheme.reload.level_clubs.first.catalog.size.should == 0
      scheme.reload.level_clubs.second.catalog.size.should == 0
    end

    it "should return active client items for a client" do
      client = Fabricate(:client)
      client_item1 = Fabricate(:client_item, :client_catalog => client.client_catalog, :deleted => true)
      client_item2 = Fabricate(:client_item, :client_catalog => client.client_catalog)
      scheme = Fabricate(:scheme, :client => client, :client_items => [client_item1, client_item2])
      scheme.active_items.count.should == 1
      scheme.active_items.should == [client_item2]
    end

    context "points" do
      it "should return minimum scheme points" do
        client = Fabricate(:client, :points_to_rupee_ratio => 2)
        client_item1 = Fabricate(:client_item, :client_price => 10_000, :client_catalog => client.client_catalog)
        client_item2 = Fabricate(:client_item, :client_price => 20_000, :client_catalog => client.client_catalog)
        scheme = Fabricate(:scheme, :client => client, :client_items => [client_item1, client_item2])
        scheme.minimum_point.should == 20_000
        scheme.maximum_point.should == 40_000
      end

      it "should return minimum client point when points to rupee ratio is not an integer" do
        client = Fabricate(:client, :points_to_rupee_ratio => 1.5)
        client_item1 = Fabricate(:client_item, :client_price => 10_000, :client_catalog => client.client_catalog)
        client_item2 = Fabricate(:client_item, :client_price => 20_000, :client_catalog => client.client_catalog)
        scheme = Fabricate(:scheme, :client => client, :client_items => [client_item1, client_item2])
        scheme.minimum_point.should == 15_000
        scheme.maximum_point.should == 30_000
      end

      it "should return 0 if no active client item found " do
        client = Fabricate(:client, :points_to_rupee_ratio => 2)

        client_item = Fabricate(:client_item, :client_price => 10_000, :client_catalog => client.client_catalog, :deleted => true)
        scheme = Fabricate(:scheme, :client => client, :client_items => [client_item])
        scheme.minimum_point.should == 0
        scheme.maximum_point.should == 0
      end
    end
  end

  context "scopes" do
    it "should return schemes whose redemption end date is lesser than today" do
      expired_scheme1 = Fabricate(:expired_scheme)
      expired_scheme2 = Fabricate(:expired_scheme)
      not_yet_started_scheme = Fabricate(:not_yet_started_scheme)

      Scheme.expired.should == [expired_scheme1, expired_scheme2]
    end

    it "should return schemes whose redemption has begun but not closed" do
      expired_scheme1 = Fabricate(:expired_scheme)
      not_yet_started_scheme = Fabricate(:not_yet_started_scheme)
      redeemable_scheme2 = Fabricate(:scheme, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today+ 10.days)
      redeemable_scheme3 = Fabricate(:scheme, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.tomorrow)

      Scheme.redeemable.should =~ [redeemable_scheme2, redeemable_scheme3]
      Scheme.redeemable_or_expired.should =~ [expired_scheme1, redeemable_scheme2, redeemable_scheme3]
    end

    it "should return schemes whose redemption has not started" do
      yet_to_start_scheme = Fabricate(:scheme, :start_date => Date.tomorrow, :end_date => Date.tomorrow + 60.days, :redemption_start_date => Date.tomorrow + 30.days, :redemption_end_date => Date.today + 40.days)
      upcoming_scheme = Fabricate(:scheme, :start_date => Date.today - 20.days, :redemption_start_date => Date.tomorrow, :redemption_end_date => Date.today + 2.days)
      expired_scheme = Fabricate(:expired_scheme, :redemption_end_date => Date.yesterday)

      Scheme.pre_redemption.should == [upcoming_scheme]
    end
  end

end