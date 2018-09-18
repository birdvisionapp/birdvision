require 'spec_helper'

describe Order do
  it { should belong_to(:user) }
  it { should have_many(:order_items) }

  it { should allow_mass_assignment_of :user }
  it { should allow_mass_assignment_of :address_name }
  it { should allow_mass_assignment_of :address_body }
  it { should allow_mass_assignment_of :address_city }
  it { should allow_mass_assignment_of :address_state }
  it { should allow_mass_assignment_of :address_zip_code }
  it { should allow_mass_assignment_of :address_phone }
  it { should allow_mass_assignment_of :address_landmark }
  it { should allow_mass_assignment_of :address_landline_phone }
  it { should allow_mass_assignment_of :order_items }

  it { should validate_presence_of(:address_name) }
  it { should validate_presence_of(:address_city) }
  it { should validate_presence_of(:address_state) }
  it { should validate_presence_of(:address_phone) }
  it { should validate_presence_of(:address_name) }

  xit { should validate_format_of(:address_name) }
  it { should ensure_length_of(:address_body).is_at_least(6) }
  it { should validate_format_of(:address_zip_code).not_with('wrong1').with_message("Please enter a valid pin code - Eg. 411007") }
  it { should validate_format_of(:address_zip_code).with('60601').with_message("Address zipcode 0should be exact six digits Eg. 411001 (\"60601\")") }

  it { should validate_numericality_of(:address_phone).only_integer.with_message(/.*/) }
  xit { should ensure_length_of(:address_phone).is_equal_to(10).with_long_message(/Address phone is the wrong length/).with_short_message(/Address phone is the wrong length/) }

  context "place" do
    before(:each) do
      user_scheme = Fabricate(:user_scheme, :total_points => 53_000, :scheme => Fabricate(:scheme))
      @user = user_scheme.user
    end

    def some_order(cart)
      order = cart.build_order_for(@user.schemes.first)
      order.assign_attributes({"address_name" => "Tester", "address_body" => "Yerwada",
                               "address_city" => "Pune", "address_state" => "MH",
                               "address_zip_code" => "411006", "address_phone" => "7798987102",
                               "address_landmark" => ""})
      order
    end

    context "success" do

      before(:each) {
        client_item = Fabricate(:client_item, :client_price => 5_000)
        @user_scheme = @user.user_schemes.first
        Fabricate(:cart_item, :cart => @user_scheme.cart, :client_item => client_item)
        @order = some_order(@user_scheme.cart)
      }

      it "should create order" do
        expect {
          @order.place_order @user_scheme
        }.to change { Order.count }.by(1)
        @order.points.should == @order.total
      end

      it "should clear cart if order is placed successfully" do
        expect {
          @order.place_order @user_scheme
        }.to change { @user_scheme.reload.cart.cart_items.size }.from(1).to(0)
      end

      it "should consume user points if order is placed successfully" do
        expect {
          @order.place_order @user_scheme
        }.to change { @user.reload.total_redeemable_points }.from(53000).to(3000)
      end

      it "should return true" do
        @order.place_order(@user_scheme).should be_true
      end
    end

    context "failure" do

      before(:each) {
        @user_scheme = @user.user_schemes.first
        cart = @user_scheme.cart
        Fabricate(:cart_item, :cart => cart)
        @order = cart.build_order_for(@user.schemes.first)
      }

      it "should not clear cart if order is not placed successfully" do
        expect {
          @order.place_order @user_scheme
        }.to_not change { @user_scheme.reload.cart.cart_items.size }
      end

      it "should not consume user points if order is not placed successfully" do
        expect {
          @order.place_order @user_scheme
        }.to_not change { @user.reload.total_redeemable_points }
      end

      it "should return false" do
        @order.place_order(@user_scheme).should be_false
      end

    end
  end

  it "should return complete address to be shown in csv" do
    user = Fabricate(:user)
    order = Fabricate(:order, :user => user)
    order.complete_address_for_show.should == "tester,<br>Yerwada,<br>Don Bosco School,<br>Pune-411006,<br>MH,<br>Phone:7798987102"
  end
end
