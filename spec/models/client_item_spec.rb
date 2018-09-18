require 'spec_helper'

describe ClientItem do
  it { should belong_to :item }
  it { should belong_to :client_catalog }
  it { should have_many :catalog_items }
  it { should have_many(:level_clubs).through(:catalog_items) }
  it { should have_many(:schemes).through(:catalog_items) }
  it { should have_one(:client).through(:client_catalog) }
  it { should allow_mass_assignment_of :item_id }
  it { should allow_mass_assignment_of :margin }
  it { should allow_mass_assignment_of :client_catalog_id }
  it { should allow_mass_assignment_of :client_price }
  it { should allow_mass_assignment_of :deleted }
  it { should validate_presence_of(:item_id) }
  it { should validate_numericality_of(:client_price) }
  it { should be_trailed }

  it "should calculate margin before saving client item" do
    client_item = Fabricate(:client_item, :client_price => 10_000, :item => Fabricate(:item, :bvc_price => 8_000))
    client_item.margin.should == 25.0
  end

  it "should save client item slug" do
    client_item = Fabricate(:client_item)
    client_item.slug.should == client_item.item.slug
  end

  it "should return to_param as slug" do
    client_item = Fabricate(:client_item)
    client_item.to_param.should == client_item.slug
  end

  it "should return title of item" do
    client_item = Fabricate(:client_item)
    client_item.title.should == client_item.item.title
  end

  it "should soft delete client item" do
    client_item = Fabricate(:client_item, :deleted => false)
    client_item.soft_delete
    client_item.deleted.should be_true
  end
  it "should delete catalog items while soft deleting client item" do
    client_item = Fabricate(:client_item)
    level_club = Fabricate(:level_club)
    level_club.catalog.add([client_item])
    level_club.catalog_items.size.should == 1

    client_item.soft_delete

    client_item.reload.catalog_items.should == []
    level_club.reload.catalog_items.size.should == 0
    CatalogItem.find_by_client_item_id(client_item.id).should be_nil
  end

  it "should return price converted to points" do
    client_item = Fabricate(:client_item)
    client_item.price_to_points.should == client_item.client_price * client_item.client.points_to_rupee_ratio
  end

  it "should not return converted price if price is missing" do
    client_item = Fabricate(:client_item, :client_price => nil)
    client_item.price_to_points.should == nil
  end

  context "scopes" do
    let(:scheme) { Fabricate(:scheme) }
    it "should return active client items" do
      client_item1 = Fabricate(:client_item)
      client_item2 = Fabricate(:client_item, :client_price => "")
      client_item3 = Fabricate(:client_item, :client_price => nil)
      ClientItem.active_items.should == [client_item1]
    end

    it "should return featured client items for given level_club" do
      client_item1 = Fabricate(:client_item)
      client_item2 = Fabricate(:client_item)
      level_club1 = Fabricate(:level_club)
      level_club1.catalog.add([client_item1])
      level_club2 = Fabricate(:level_club)
      level_club2.catalog.add([client_item2])

      ClientItem.featured_items(level_club2).should == [client_item2]
    end

    it "should return top 5 client items sorted in descending order for the carousel" do
      client_items = (1..6).to_a.collect do |index|
        Fabricate(:client_item, :client_catalog => scheme.client.client_catalog, :client_price => 10000 * index)
      end
      scheme.client_items = client_items
      level_club_for(scheme, "level1", "platinum").catalog.add(client_items)

      featured_items = ClientItem.featured_items(scheme.level_clubs)
      featured_items.length.should == 5
      featured_items[0].should == client_items[5]
      featured_items[4].should == client_items[1]
    end

    it "should show only those items for which client price is set" do
      client_item1 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog)
      client_item2 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog, :client_price => nil)
      client_items = [client_item1, client_item2]
      scheme.client_items = client_items
      level_club_for(scheme, "level1", "platinum").catalog.add(client_items)

      ClientItem.featured_items(scheme.level_clubs).should == [client_item1]
    end

    it "should show only those items which are not deleted" do
      client_item1 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog)
      client_item2 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog, :client_price => nil)
      client_item3 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog, :deleted => true)
      client_items = [client_item1, client_item2, client_item3]
      scheme.client_items = client_items
      level_club_for(scheme, "level1", "platinum").catalog.add(client_items)

      ClientItem.featured_items(scheme.level_clubs).should == [client_item1]
    end

    it "should sort client items in ascending order of client price" do
      client_item1 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog, :client_price => 5_000)
      client_item2 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog, :client_price => 10_000)
      client_items = [client_item2, client_item1]
      scheme.client_items = client_items
      level_club_for(scheme, 'level1', 'platinum').catalog.add(client_items)

      ClientItem.featured_items(scheme.level_clubs).should == client_items
    end

    it "should return client items corresponding to specified catalog items" do
      client_item1 = Fabricate(:client_item)
      catalog_item1 = Fabricate(:catalog_item, :client_item => client_item1)
      irrelevant_catalog_item = Fabricate(:catalog_item, :client_item => Fabricate(:client_item))

      ClientItem.for_catalog_items([catalog_item1]).should == [client_item1]
    end

    it "should return client items belonging to specified level clubs" do
      scheme = Fabricate(:scheme_3x3, :levels => %w(level1 level2 level3), :clubs => %w(platinum gold silver))
      level1_level_clubs = scheme.level_clubs.with_level('level1')

      client_item1 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog)
      client_item2 = Fabricate(:client_item, :client_catalog => scheme.client.client_catalog)
      scheme.client_items = [client_item1, client_item2]
      level_club_for(scheme, 'level1', 'platinum').catalog.add([client_item1])
      level_club_for(scheme, 'level2', 'platinum').catalog.add([client_item2])

      ClientItem.with_level_clubs(level1_level_clubs).should == [client_item1]
    end

    context "item_redeemable" do
      it "should return false if user's scheme is currently not redeemable" do
        scheme = Fabricate(:expired_scheme, :single_redemption => true, :client => Fabricate(:client))
        user = Fabricate(:user, :client => scheme.client)
        user_scheme = Fabricate(:user_scheme, :user => user, :scheme => scheme)

        update_level_club(user_scheme, "level1", "platinum")
        client_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => user.client.client_catalog)

        level_club_for(scheme, 'level1', 'platinum').catalog.add([client_item])

        client_item.item_redeemable?(user_scheme).should be_false
      end

      it "should return false if user has already redeemed an item" do
        user = Fabricate(:user)
        scheme = Fabricate(:scheme)
        user_scheme = Fabricate(:single_redemption_user_scheme, :user => user, :scheme => scheme)
        update_level_club(user_scheme, "level1", "platinum")

        user_scheme.stub(:redemption_active?).and_return(true)
        user_scheme.stub(:redeemable?).and_return(false)
        item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => user.client.client_catalog)

        item.item_redeemable?(user_scheme).should be_false
      end

      it "should return false if item is not in level club catalog og the users club" do
        user = Fabricate(:user)
        scheme = Fabricate(:scheme)
        user_scheme = Fabricate(:single_redemption_user_scheme, :user => user, :scheme => scheme)
        update_level_club(user_scheme, "level1", nil)

        user_scheme.stub(:redemption_active?).and_return(true)
        user_scheme.stub(:redeemable?).and_return(true)
        item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => user.client.client_catalog)

        item.item_redeemable?(user_scheme).should be_false
      end

      it "should return true for non-single redemption active scheme" do
        user = Fabricate(:user)
        user_scheme = Fabricate(:user_scheme, :user => user, :scheme => Fabricate(:scheme))
        update_level_club(user_scheme, "level1", "platinum")
        Fabricate(:order_item, :scheme => user_scheme.scheme, :order => Fabricate(:order, :user => user))
        item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => user.client.client_catalog)
        level_club_for(user_scheme.scheme, 'level1', 'platinum').catalog.add([item])

        item.item_redeemable?(user_scheme).should be_true
      end

      it "should return true for items which belong to lower clubs" do
        user = Fabricate(:user)
        user_scheme = Fabricate(:user_scheme, :user => user, :scheme => Fabricate(:scheme_3x3))
        update_level_club(user_scheme, "level1", "platinum")

        item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => user.client.client_catalog)
        level_club_for(user_scheme.scheme, 'level1', 'gold').catalog.add([item])

        item.item_redeemable?(user_scheme).should be_true
      end
    end
  end
end
