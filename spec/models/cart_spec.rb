require 'spec_helper'

describe Cart do

  it { should have_many(:cart_items) }
  it { should belong_to(:user_scheme) }

  context "add item" do

    let(:user_scheme) { Fabricate(:user_scheme, :scheme => Fabricate(:scheme)) }
    let(:user) { user_scheme.user }
    let(:cart) { user_scheme.cart }

    it "should add item to cart" do
      client_item = Fabricate(:client_item, :client_price => 5_000)
      cart.add_client_item(client_item)

      cart.cart_items.size.should == 1
      cart.cart_items.first.client_item.item.should == client_item.item
      cart.total_points.should == client_item.price_to_points
    end

    it "should increment quantity of item given that the cart already has the item" do
      client_item = Fabricate(:client_item, :client_price => 5_000)

      cart.add_client_item(client_item)
      cart.add_client_item(client_item)

      cart.cart_items.size.should == 1
      cart.cart_items.first.quantity.should == 2
      cart.total_points.should == client_item.price_to_points * 2
    end

  end

  context "remove item" do

    it "should remove item from cart" do
      cart_item1 = Fabricate.build(:cart_item)
      cart_item2 = Fabricate.build(:cart_item)
      cart = Fabricate.build(:cart, :cart_items => [cart_item1, cart_item2])
      cart.remove_item(cart_item1.client_item)

      cart.cart_items.size.should == 1
    end

    it "should not raise an error if specified item does not exist in cart" do
      cart = Fabricate.build(:cart)
      cart_item = Fabricate.build(:cart_item)

      expect { cart.remove_item(cart_item.client_item) }.to_not raise_error
      cart.cart_items.should be_empty
    end
  end

  context "items" do
    let(:user_scheme) { Fabricate(:user_scheme, :scheme => Fabricate(:scheme)) }
    let(:user) { user_scheme.user }
    let(:cart) { user_scheme.cart }

    it "should tell if cart has no items" do
      cart.empty?.should == true
    end

    it "should tell if cart has items" do
      item = Fabricate(:item)
      cart.add_client_item item

      cart.empty?.should == false
    end

    it "should calculate total points of all items in cart" do
      user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme))
      user_scheme.update_attribute(:total_points, 10_00_000)

      client_item1 = Fabricate(:client_item, :client_price => 10_000)
      client_item2 = Fabricate(:client_item, :client_price => 1_20_000)

      cart.add_client_item client_item1
      cart.add_client_item client_item2

      cart.cart_items.size.should == 2
      cart.total_points.should == client_item1.price_to_points + client_item2.price_to_points
    end

    it "should calculate total count of all items in cart" do
      cart.user_scheme.update_attribute(:total_points, 2_00_000)
      client_item1 = Fabricate(:client_item, :client_price => 5_000)
      client_item2 = Fabricate(:client_item, :client_price => 5_000)

      cart.add_client_item client_item1
      cart.add_client_item client_item2

      cart.size.should == 2
    end

  end

  context "build order" do
    let(:user_scheme) { Fabricate(:user_scheme, :scheme => Fabricate(:scheme)) }
    let(:user) { user_scheme.user }
    let(:cart) { user_scheme.cart }

    it "should build order given cart with items with ordered by updated_at" do
      client_item1 = Fabricate(:client_item, :client_price => 5_000)
      client_item2 = Fabricate(:client_item, :client_price => 5_000)

      cart.add_client_item(client_item1)
      cart.add_client_item(client_item2)

      order = cart.build_order_for(cart.user_scheme.scheme)
      order.order_items.size.should == 2
      order.order_items.first.client_item.item.should == client_item2.item
      order.order_items.last.client_item.item.should == client_item1.item
    end

    it "should build order with address attributes" do
      cart.add_client_item(Fabricate(:client_item))

      order = cart.build_order_for(cart.user_scheme.scheme, {:address_state => 'goa'})

      order.address_state.should == 'goa'
    end

    it "should build order even without address attributes" do
      cart.add_client_item(Fabricate(:client_item))

      order = cart.build_order_for(cart.user_scheme.scheme, nil)

      order.user.should == cart.user_scheme.user
    end

    it "should build order with client item attributes" do
      client_item1 = Fabricate(:client_item, :client_price => 6_000)
      cart.add_client_item(client_item1)
      order = cart.build_order_for(cart.user_scheme.scheme)
      order.order_items.first.points_claimed.should == cart.cart_items.first.total_price_in_points
      order.order_items.first.price_in_rupees.should == cart.cart_items.first.client_item.client_price * cart.cart_items.first.quantity
      #TODO: Fix and check why bvc_margin calculations are wrong.
      #order.order_items.first.bvc_margin.should == cart.cart_items.first.client_item.item.update_bvc_margin
      order.order_items.first.bvc_price.should == cart.cart_items.first.client_item.item.bvc_price
      order.order_items.first.channel_price.should == cart.cart_items.first.client_item.item.channel_price
    end
  end
end
