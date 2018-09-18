require 'spec_helper'

describe SingleRedemption::RedemptionController do
  context "routes" do
    it "should route requests correctly" do
      {:post => single_redemption_redemption_path(:scheme_slug => 'some_scheme')}.should route_to("single_redemption/redemption#redeem", :scheme_slug => "some_scheme")
    end
  end

  login_user
  context "redeem" do
    before(:each) do
      scheme = Fabricate(:scheme_3x3, :single_redemption => true, :client => @user.client)
      user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => scheme)
      update_level_club(user_scheme, 'level1', 'gold')

      @client = @user.client
      @other_level_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Other level Canon 1D'), :client_catalog => @client.client_catalog)
      @other_club_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Other club Canon 1D'), :client_catalog => @client.client_catalog)
      @item1 = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => @client.client_catalog)
      @inactive_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Gold Canon 1D'), :client_catalog => @client.client_catalog, :deleted => true)
      @item2 = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Silver Canon 1D'), :client_catalog => @client.client_catalog)

      scheme.catalog.add([@other_level_item, @inactive_item, @other_club_item, @item2, @item1])

      level_club_for(scheme, 'level3', 'gold').catalog.add([@other_level_item])
      level_club_for(scheme, 'level1', 'gold').catalog.add([@item1, @item2, @inactive_item])
      level_club_for(scheme, 'level1', 'platinum').catalog.add([@other_club_item])
    end

    it "should populate cart with given item" do
      user_scheme = @user.user_schemes.first
      post :redeem, :id => @item1.slug, :scheme_slug => user_scheme.scheme.slug

      user_scheme.cart.size.should == 1
      user_scheme.cart.cart_items.first.client_item.should == @item1
    end

    it "should not add non active items to cart" do
      expect {
        post :redeem, :id => @inactive_item.slug, :scheme_slug => @user.user_schemes.first.scheme.slug
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "should replace older items in the cart with the latest one which got added" do
      user_scheme = @user.user_schemes.first

      user_scheme.cart.add_client_item(@item1)
      user_scheme.cart.save!

      post :redeem, :id => @item2.slug, :scheme_slug => @user.user_schemes.first.scheme.slug

      response.should redirect_to(new_order_path(:scheme_slug => @user.user_schemes.first.scheme.slug))
      user_scheme.cart.reload.size.should == 1
      user_scheme.cart.cart_items.first.client_item.should == @item2
    end

    it "should not allow redemption of items belonging to other level" do
      expect {
        post :redeem, :id => @other_level_item.slug, :scheme_slug => @user.user_schemes.first.scheme.slug
      }.to raise_error ActiveRecord::RecordNotFound
    end
    it "should not allow redemption of items belonging to higher club" do
      post :redeem, :id => @other_club_item.slug, :scheme_slug => @user.user_schemes.first.scheme.slug

      response.status.should == 401
    end
  end
end