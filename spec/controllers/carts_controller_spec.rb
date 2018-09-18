require 'spec_helper'

describe CartsController do
  login_user

  before :each do
    request.env["HTTP_REFERER"] = root_url
    Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
  end

  let(:user_scheme) { @user.user_schemes.first }
  let(:scheme) { user_scheme.scheme }

  context "routes" do
    it "should route requests correctly" do
      {:post => add_to_cart_path(:scheme_slug => scheme.slug)}.should route_to('carts#add_item', :scheme_slug => scheme.slug)
      {:get => add_to_cart_path(:scheme_slug => scheme.slug)}.should route_to('carts#add_item', :scheme_slug => scheme.slug)
      {:put => update_quantity_path(:scheme_slug => scheme.slug)}.should route_to('carts#update_item_quantity', :scheme_slug => scheme.slug)
      {:get => carts_path(:scheme_slug => scheme.slug)}.should route_to('carts#index', :scheme_slug => scheme.slug)
      {:delete => remove_from_cart_path(:id => 'mobile', :scheme_slug => scheme.slug)}.should route_to('carts#remove_item', :id => 'mobile', :scheme_slug => scheme.slug)
    end
  end

  context "add to cart" do
    it "should add items to cart" do
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog)
      scheme.catalog.add([client_item])
      scheme.level_clubs.first.catalog.add([client_item])

      post :add_item, :id => client_item.slug, :scheme_slug => scheme.slug

      response.should redirect_to "#{carts_path(:scheme_slug => scheme.slug)}"
    end

    it "should add to cart even via get request" do
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog)
      scheme.catalog.add([client_item])
      scheme.level_clubs.first.catalog.add([client_item])

      get :add_item, :id => client_item.slug, :scheme_slug => scheme.slug

      response.should redirect_to "#{carts_path(:scheme_slug => scheme.slug)}"
      user_scheme.cart.size.should == 1
    end

    it "should not add non active items to cart" do
      item_to_add = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :deleted => true)

      expect {
        post :add_item, :id => item_to_add.slug, :scheme_slug => scheme.slug
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "should increment quantity if given item already exists in cart" do
      user_scheme = @user.user_schemes.first
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog)
      existing_item = Fabricate(:cart_item, :cart => user_scheme.cart, :client_item => client_item)
      user_scheme.scheme.catalog.add([client_item])
      level_club_for(user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])

      post :add_item, :id => existing_item.client_item.slug, :scheme_slug => scheme.slug

      response.should redirect_to "#{carts_path(:scheme_slug => user_scheme.scheme.slug)}"
      user_scheme.cart.cart_items.count.should == 1
      user_scheme.cart.cart_items.first.quantity.should == 2
    end

    it "should throw an exception if item being added is not found" do
      user_scheme = @user.user_schemes.first

      expect {
        post :add_item, :id => "test", :scheme_slug => user_scheme.scheme.slug
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "should raise exception if given item is not in level club catalog" do
      scheme = Fabricate(:scheme, :name => 'Dhamaka scheme', :client => @user.client, :levels => %w(level1 level2), :clubs => %w(platinum))
      user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => scheme)
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog)
      user_scheme.scheme.catalog.add([client_item])
      level_club_for(user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])
      update_level_club(user_scheme, 'level2', nil)
      expect {
        post :add_item, :id => client_item.slug, :scheme_slug => user_scheme.scheme.slug
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "update item quantity" do
    it "should update quantity " do
      user_scheme = @user.user_schemes.first

      cart = user_scheme.cart
      cart_item = Fabricate(:cart_item, :client_item => Fabricate(:client_item, :client_price => 100), :cart => cart, :quantity => 2)

      cart.total_points.should == 2000

      put :update_item_quantity, :cart_item => {:id => cart_item.id, :quantity => 10}, :scheme_slug => scheme.slug

      cart.reload.cart_items.first.quantity.should ==10
      cart.total_points.should == 10000
      response.should redirect_to carts_path(:scheme_slug => user_scheme.scheme.slug)
    end

    it "should render error if update fails" do
      user_scheme = @user.user_schemes.first

      cart = user_scheme.cart
      cart_item = Fabricate(:cart_item, :client_item => Fabricate(:client_item, :client_price => 100), :cart => cart, :quantity => 2)

      post :update_item_quantity, :cart_item => {:id => cart_item.id, :quantity => -10}, :scheme_slug => user_scheme.scheme.slug

      flash[:alert].should == "Please enter valid quantity"
      response.should redirect_to carts_path(:scheme_slug => user_scheme.scheme.slug)
    end
  end

  context "show cart" do

    it "should show cart if not empty" do
      user_scheme = @user.user_schemes.first

      cart = user_scheme.cart
      Fabricate(:cart_item, :cart => cart)

      get :index, :scheme_slug => user_scheme.scheme.slug

      assigns[:cart].should == cart
      assigns[:user_scheme].should == @user.user_schemes.first
    end

    it "should show items in cart specific to scheme" do
      old_user_scheme = @user.user_schemes.first
      new_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :name => "new scheme name", :client => @user.client))

      old_scheme_cart = old_user_scheme.cart
      new_scheme_cart = new_user_scheme.cart

      Fabricate(:cart_item, :cart => old_scheme_cart)
      Fabricate(:cart_item, :cart => new_user_scheme.cart)

      get :index, :scheme_slug => old_user_scheme.scheme.slug

      assigns[:cart].should == old_scheme_cart
      assigns[:user_scheme].should == old_user_scheme

      get :index, :scheme_slug => new_user_scheme.scheme.slug

      assigns[:cart].should == new_scheme_cart
      assigns[:user_scheme].should == new_user_scheme
    end

    it "should show message if cart is empty" do
      get :index, :scheme_slug => scheme.slug

      response.should be_ok
      flash[:info].should == "Your cart is empty"
    end

    it "should show message if scheme is future scheme" do
      user = Fabricate(:user)
      future_scheme = Fabricate(:future_scheme, :client => user.client, :name => "c")
      user_scheme = Fabricate(:user_scheme, :user => user, :scheme => future_scheme)
      client_item = Fabricate(:client_item, :client_catalog => user.client.client_catalog, :deleted => false)
      user_scheme.scheme.client_items << client_item
      cart_item = Fabricate(:cart_item, :cart => user_scheme.cart, :client_item => client_item)
      level_club_for(future_scheme, 'level1', 'platinum').catalog.add([client_item])

      sign_in user

      get :index, :scheme_slug => future_scheme.slug

      response.should be_ok
      flash[:info].should == "You can redeem this cart once this scheme's redemption begins"
    end

    context "admin removes item" do
      let(:user_scheme) { @user.user_schemes.first }
      it "should remove cart item if corresponding client item is deleted from client catalog" do
        client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :deleted => true)
        user_scheme.scheme.client_items << client_item
        level_club_for(user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])
        cart_item = Fabricate(:cart_item, :cart => user_scheme.cart, :client_item => client_item)

        get :index, :scheme_slug => user_scheme.scheme.slug

        response.should be_ok
        user_scheme.cart.should be_empty
        flash[:info].should == "Your cart is empty"
      end
      it "should remove cart item if corresponding client item is deleted from applicable level club catalogs" do
        client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :deleted => false)
        user_scheme.scheme.catalog.add([client_item])
        # item not present in level_club catalogs
        cart_item = Fabricate(:cart_item, :cart => user_scheme.cart, :client_item => client_item)

        get :index, :scheme_slug => user_scheme.scheme.slug

        response.should be_ok
        user_scheme.cart.should be_empty
      end
    end
  end

  context "remove from cart" do
    it "should delete existing item" do
      user_scheme = @user.user_schemes.first

      cart = user_scheme.cart
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog)
      cart_item = Fabricate(:cart_item, :cart => cart, :client_item => client_item)
      Fabricate(:cart_item, :cart => cart, :client_item => client_item)

      delete :remove_item, :id => cart_item.client_item.id, :scheme_slug => user_scheme.scheme.slug

      flash[:notice].should == "The Item #{cart_item.client_item.item.title} has been removed from your Cart, you can add it again from your Catalog."
      response.should redirect_to carts_path(:scheme_slug => user_scheme.scheme.slug)
      cart.cart_items.count.should == 1
    end

  end
end