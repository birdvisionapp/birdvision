require 'spec_helper'

describe UserScheme do
  it { should belong_to(:user) }
  it { should belong_to(:scheme) }
  it { should have_one(:cart) }
  it { should have_many(:targets) }

  it { should belong_to(:level) }
  it { should belong_to(:club) }

  it { should allow_mass_assignment_of :user_id }
  it { should allow_mass_assignment_of :scheme_id }
  it { should allow_mass_assignment_of :total_points }
  it { should allow_mass_assignment_of :redeemed_points }
  it { should allow_mass_assignment_of :targets }

  it { should validate_numericality_of(:total_points) }
  it { should validate_numericality_of(:redeemed_points) }

  it { should_not allow_value(-1).for(:total_points) }
  it { should_not allow_value(-1).for(:redeemed_points) }

  it { should allow_value(0).for(:redeemed_points) }

  it { should allow_mass_assignment_of :current_achievements }
  it { should allow_mass_assignment_of :region }

  it { should validate_numericality_of(:current_achievements) }
  it { should_not allow_value(-1).for(:current_achievements) }

  it { should validate_presence_of(:level) }
  it { should allow_mass_assignment_of :club }
  it { should allow_mass_assignment_of :level }
  it { should be_trailed }

  it "should skip validation for club name if club is not provided" do
    expect { Fabricate(:user_scheme, :scheme => Fabricate(:scheme), :club => nil) }.not_to raise_error ActiveRecord::RecordInvalid
  end

  it "should validate if given level for a user is present for that scheme" do
    incorrect_level = Fabricate(:level, :name => "new name")

    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme))
    expect { user_scheme.update_attributes!(:level => incorrect_level) }.to raise_error ActiveRecord::RecordInvalid
  end

  it "should validate if given club for a user is present for that scheme" do
    incorrect_club = Fabricate(:club, :name => "new name")

    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme))
    expect { user_scheme.update_attributes!(:club => incorrect_club) }.to raise_error ActiveRecord::RecordInvalid
  end

  it "should return user scheme for the user scoping by client" do
    emerson = Fabricate(:client, :client_name => "emerson")
    scheme1 = Fabricate(:scheme, :client => emerson, :name => "scheme")
    user1 = Fabricate(:user, :client => emerson)
    user_scheme1 = Fabricate(:user_scheme, :user => user1, :scheme => scheme1)

    axis = Fabricate(:client, :client_name => "axis")
    scheme2 = Fabricate(:scheme, :client => axis, :name => "scheme")
    user2 = Fabricate(:user, :client => axis)
    user_scheme2 = Fabricate(:user_scheme, :user => user2, :scheme => scheme2)

    UserScheme.for_user(user1, scheme1.slug).should == [user_scheme1]
    UserScheme.for_user(user2, scheme2.slug).should == [user_scheme2]
  end

  it "should return user scheme for the user for which points can be clubbed" do
    acme = Fabricate(:client, :client_name => "acme")
    scheme1 = Fabricate(:scheme, :client => acme, :name => "scheme1")
    user1 = Fabricate(:user)
    user_scheme1 = Fabricate(:user_scheme, :user => user1, :scheme => scheme1)

    scheme2 = Fabricate(:scheme, :single_redemption => true, :client => acme, :name => "scheme2")
    user_scheme2 = Fabricate(:user_scheme, :user => user1, :scheme => scheme2)

    UserScheme.clubbable.should == [user_scheme1]
  end

  it "should return true if redemption for a scheme is over" do
    scheme = Fabricate(:expired_scheme)
    user_scheme = Fabricate(:user_scheme, :scheme => scheme)
    user_scheme.redemption_over?.should == true
  end

  it "should identify if scheme redemption is active" do
    user_scheme = Fabricate.build(:user_scheme, :scheme => Fabricate.build(:scheme, :redemption_start_date => Date.yesterday))

    user_scheme.redemption_active?.should be_true
  end

  context "cart" do
    it "should tell if user has sufficient points to redeem cart" do
      user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme))
      cart = user_scheme.cart
      cart.add_client_item Fabricate(:client_item, :client_price => 5_000)
      user_scheme.has_sufficient_points?.should be_true

      cart.add_client_item Fabricate(:client_item, :client_price => 15_00_00)
      user_scheme.has_sufficient_points?.should be_false
    end

    it "should have cart associate with it" do
      user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme))
      user_scheme.reload.cart.should_not be_nil
    end

    it "should return all active and future user_schemes" do
      client = Fabricate(:client)
      scheme = Fabricate(:scheme, :client => client, :name => "a")
      past_scheme = Fabricate(:expired_scheme, :client => client, :name => "b")
      future_scheme = Fabricate(:future_scheme, :client => client, :name => "c")
      not_started_scheme = Fabricate(:not_yet_started_scheme, :client => client, :name => "d")

      user = Fabricate(:user, :client => client)
      user_scheme = Fabricate(:user_scheme, :user => user, :scheme => scheme)
      past_user_scheme = Fabricate(:user_scheme, :user => user, :scheme => past_scheme)
      future_user_scheme = Fabricate(:user_scheme, :user => user, :scheme => future_scheme)
      not_started_user_scheme = Fabricate(:user_scheme, :user => user, :scheme => not_started_scheme)

      user.user_schemes.browsable.should == [user_scheme, future_user_scheme]
    end

  end

  context "redemption" do
    it "cannot redeem points if user does not have any active scheme" do
      active_scheme = Fabricate(:scheme, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.tomorrow)
      past_scheme = Fabricate(:scheme, :redemption_start_date => Date.today - 5.days, :redemption_end_date => Date.yesterday)
      future_scheme = Fabricate(:future_scheme)
      user = Fabricate(:user)
      create_user_schemes_for user, [active_scheme, past_scheme, future_scheme]

      user.user_schemes.first.redemption_active?.should be_true
      user.user_schemes.second.redemption_active?.should be_false
      user.user_schemes.third.redemption_active?.should be_false
    end

    it "should allow redemption if any of the schemes allows redemption" do
      scheme1 = Fabricate(:scheme, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.tomorrow)
      user = Fabricate(:user)
      create_user_schemes_for user, [scheme1]

      user.user_schemes.first.redemption_active?.should be_true
    end

    it "should redeem points from active scheme even if points are greater than total_points in active scheme" do
      active_scheme = Fabricate(:scheme, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.tomorrow)
      scheme2 = Fabricate(:scheme, :redemption_start_date => Date.yesterday - 1, :redemption_end_date => Date.yesterday)
      user = Fabricate(:user)
      active_user_scheme = Fabricate(:user_scheme, :scheme => active_scheme, :user => user, :total_points => 1_000, :redeemed_points => 0)
      Fabricate(:user_scheme, :scheme => scheme2, :user => user, :total_points => 2_000, :redeemed_points => 1_400)
      active_user_scheme.cart.stub(:total_points).and_return(1200)

      active_user_scheme.redeem

      active_user_scheme.reload.redeemed_points.should == 1200
    end
  end

  context "orders" do
    it "should return all orders for the scheme for point based client" do
      client = Fabricate(:client)
      scheme = Fabricate(:scheme, :client => client)
      user_scheme = Fabricate(:user_scheme, :scheme => scheme)
      user_scheme2 = Fabricate(:user_scheme, :scheme => scheme)
      Fabricate(:order_item, :scheme => scheme, :order => Fabricate(:order, :user => user_scheme.user), :price_in_rupees => 200)
      Fabricate(:order_item, :scheme => scheme, :order => Fabricate(:order, :user => user_scheme.user), :price_in_rupees => 5_000)
      Fabricate(:order_item, :price_in_rupees => 5_000)
      user_scheme.orders_total.should == 5_200
      user_scheme2.orders_total.should == 0
    end
  end

  context "hook" do
    let(:active_scheme) { Fabricate(:scheme, :redemption_start_date => Date.yesterday, :redemption_end_date => Date.tomorrow) }
    it "should invoke notification on update of total points if user is point based" do
      user = Fabricate(:user, :sign_in_count => 1)
      updated_points = 1999

      user_scheme = Fabricate(:user_scheme, :scheme => active_scheme, :user => user, :total_points => 1_000, :redeemed_points => 0)
      UserSchemeNotifier.should_receive(:notify).with(user_scheme)

      user_scheme.update_attribute(:total_points, updated_points)
    end

    it "should not invoke notification on update user has not signed in so far" do
      user = Fabricate(:user, :sign_in_count => 0)
      updated_points = 1999

      user_scheme = Fabricate(:user_scheme, :scheme => active_scheme, :user => user, :total_points => 1_000, :redeemed_points => 0)
      UserSchemeNotifier.should_receive(:notify).never

      user_scheme.update_attribute(:total_points, updated_points)
    end


    context "client items" do
      before :each do
        @user = Fabricate(:user, :sign_in_count => 1)
        scheme = Fabricate(:scheme_3x3, :client => @user.client, :name => "new scheme")
        @user_scheme = Fabricate(:user_scheme, :scheme => scheme, :user => @user, :current_achievements => 1000)
        update_level_club(@user_scheme, 'level1', 'platinum')
      end

      it "should return all level-club client items for users associated with given level club for a client" do
        @user_scheme.applicable_level_clubs.size.should == 3
        @user_scheme.applicable_level_clubs.collect { |lc| lc.club.name }.should == %w(platinum gold silver)
      end
    end

  end

  context "point bounds" do
    it "should return minimum and maximum points for all applicable level clubs, and should skip deleted items" do
      client_item1 = Fabricate(:client_item, :client_price => 10_000)
      client_item2 = Fabricate(:client_item, :client_price => 20_000)
      client_item3 = Fabricate(:client_item, :client_price => 30_000, :deleted => true)
      scheme = Fabricate(:scheme)
      scheme.catalog.add([client_item1, client_item2])
      level_club_for(scheme, 'level1', 'platinum').catalog.add([client_item1, client_item2])
      user_scheme = Fabricate(:user_scheme, :scheme => scheme)
      user_scheme.minimum_points.should == 1_00_000
      user_scheme.maximum_points.should == 2_00_000
    end

  end

  context "can_add_to_cart?" do

    it "should identify if a user has redeemed any item in the current scheme" do
      user = Fabricate(:user)
      active_scheme = Fabricate(:scheme, :single_redemption => true, :name => "Scheme 2", :redemption_start_date => Date.today,
                                :redemption_end_date => Date.tomorrow, :client => user.client)
      user_scheme = Fabricate(:user_scheme, :user => user, :scheme => active_scheme)
      update_level_club(user_scheme, "level1", nil)

      order = Fabricate(:order, :user => user)
      Fabricate(:order_item, :order => order, :scheme => active_scheme)

      user_scheme.can_add_to_cart?.should be_false
    end

    it "should identify if a user has not redeemed any item in the current scheme" do
      user = Fabricate(:user)
      active_scheme = Fabricate(:scheme, :single_redemption => true, :name => "Scheme 2", :redemption_start_date => Date.today,
                                :redemption_end_date => Date.tomorrow, :client => user.client)
      user_scheme = Fabricate(:user_scheme, :user => user, :scheme => active_scheme)

      update_level_club(user_scheme, "level1", nil)

      user_scheme.can_add_to_cart?.should be_true
    end

    it "should identify if user has redeemed but order has been refunded for a scheme" do
      user = Fabricate(:user)
      active_scheme = Fabricate(:scheme, :single_redemption => true, :name => "Scheme 2", :redemption_start_date => Date.today,
                                :redemption_end_date => Date.tomorrow, :client => user.client)
      user_scheme = Fabricate(:user_scheme, :user => user, :scheme => active_scheme)

      order = Fabricate(:order, :user => user)
      Fabricate(:order_item, :order => order, :scheme => active_scheme, :status => :refunded)

      update_level_club(user_scheme, "level1", nil)

      user_scheme.can_add_to_cart?.should be_true
    end

    it "should identify if user has redeemed and no order_item has not been refunded" do
      user = Fabricate(:user)
      active_scheme = Fabricate(:scheme, :single_redemption => true, :name => "Scheme 2", :redemption_start_date => Date.today,
                                :redemption_end_date => Date.tomorrow, :client => user.client)
      user_scheme = Fabricate(:user_scheme, :user => user, :scheme => active_scheme)

      order = Fabricate(:order, :user => user)
      Fabricate(:order_item, :order => order, :scheme => active_scheme, :status => :new)

      update_level_club(user_scheme, "level1", nil)

      user_scheme.can_add_to_cart?.should be_false
    end
  end

  def create_user_schemes_for(user, schemes)
    schemes.each do |scheme|
      Fabricate(:user_scheme, :user => user, :scheme => scheme)
    end
  end
end