require 'spec_helper'

describe CartItem do

  context "validation" do

    it { should allow_mass_assignment_of :client_item_id }
    it { should allow_mass_assignment_of :cart_id }
    it { should allow_mass_assignment_of :quantity }
    it { should belong_to(:cart) }
    it { should belong_to(:client_item) }
    it { should validate_numericality_of(:quantity).with_message("Please enter valid quantity") }

    it "should update quantity of an item in cart" do
      cart_item = Fabricate.build(:cart_item, :quantity => 2)
      cart_item.update_quantity(10)
      cart_item.quantity.should == 10
    end

    it "should not allow zero quantity" do
      cart_item = Fabricate(:cart_item, :quantity => 1)
      cart_item.update_quantity(0)

      cart_item.reload.errors.count.should == 1
      cart_item.errors.first.should == [:quantity, "Please enter valid quantity"]
      cart_item.quantity.should == 1
    end

    it "should not allow negative quantity" do
      cart_item = Fabricate(:cart_item, :quantity => 2)
      cart_item.update_quantity(-1)
      cart_item.reload.errors.count.should == 1
      cart_item.errors.first.should == [:quantity, "Please enter valid quantity"]
      cart_item.quantity.should == 2
    end
  end

  it "should increment quantity of a cart_item" do
    cart_item = Fabricate.build(:cart_item, :quantity => 1)
    cart_item.increment
    cart_item.quantity.should == 2
  end

  it "should calculate item price" do
    cart_item = Fabricate.build(:cart_item, :quantity => 2)
    price = cart_item.total_price_in_points
    price.should == 2*cart_item.client_item.price_to_points
  end
end
