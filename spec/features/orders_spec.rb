require 'request_spec_helper'

feature "Order Spec" do
  context "point based" do
    before :each do
      @user = Fabricate(:user)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
      login_as @user
    end

    context "order address" do
      scenario "should display errors if validations fail for order creation" do
        @user_scheme.cart.add_client_item Fabricate(:client_item)
        visit(new_order_path(:scheme_slug => @user_scheme.scheme.slug))
        click_on('Confirm')
        within('.alert') do
          page.should have_content "Please enter a valid pin code - Eg. 411007"
        end
      end

      scenario "should display order info" do
        @user_scheme.cart.add_client_item Fabricate(:client_item, :item => Fabricate(:item, :title => "Ipod"), :client_price => 5_000)

        visit(new_order_path(:scheme_slug => @user.user_schemes.first.scheme.slug))

        within('#order_summary') do
          page.should have_content "Ipod ( 1 )"
          page.should have_content "Total: 50,000 points"
        end
      end

      scenario "should not display search" do
        @user_scheme.cart.add_client_item Fabricate(:client_item, :item => Fabricate(:item, :title => "Ipod"), :client_price => 5_000)
        visit(new_order_path(:scheme_slug => @user.user_schemes.first.scheme.slug))
        page.should_not have_selector("#searchForm")
      end

    end

    context "show order" do
      scenario "should display order info" do
        order_item= Fabricate(:order_item, :order => Fabricate(:order, :user => User.last), :points_claimed => 90_000)
        visit(order_path(:id => order_item.order, :scheme_slug => order_item.scheme.slug))
        within('#orderInfo') do
          page.should have_content order_item.order.order_id
          page.should have_content "Nikon Point and Shoot Camera"
          page.should have_content "90,000 1 90,000"
          page.should have_content "Total : 90,000"
          page.should have_link "My Orders", :href => order_index_path
        end
      end

      scenario "should not display search" do
        order = Fabricate(:order, :user => @user)
        Fabricate(:order_item, :order => order, :points_claimed => 90_000)

        visit(order_path(:id => order, :scheme_slug => order.order_items.first.scheme.slug))

        page.should_not have_selector("#searchForm")
      end

      scenario "should have navigation links" do
        order = Fabricate(:order, :user => @user)
        Fabricate(:order_item, :order => order, :points_claimed => 90_000)

        visit(order_path(:id => order, :scheme_slug => order.order_items.first.scheme.slug))
        page.should have_link "Add more to cart", :href => catalog_path_for(@user.user_schemes.first)
      end
    end

    context "My Orders Page" do
      scenario "should show all orders for a user" do
        order_item = Fabricate(:order_item, :order => Fabricate(:order, :user => @user), :quantity => 1, :scheme => @user_scheme.scheme, :points_claimed => 90_000)

        visit(order_index_path(:scheme_slug => @user_scheme.scheme.slug))

        within('#participantOrders') do
          page.should have_content "ORD#{order_item.id}"
          page.should have_content "Scheme"
          page.should have_content "Nikon Point and Shoot Camera"
          page.should have_content "1"
          page.should have_content "90,000"
        end
      end
    end
  end

  context "single redemption" do
    before :each do
      @user = Fabricate(:user)
      @client = @user.client
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :single_redemption => true, :client => @user.client))
      @client.update_attributes(:points_to_rupee_ratio => 1)
      @platinum_item = Fabricate(:client_item, :client_price => 600, :item => Fabricate(:item, :title => 'Platinum Canon 1D'), :client_catalog => @client.client_catalog)
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([@platinum_item])
      login_as @user
    end

    scenario "should not display total items and points on delivery address page" do
      @user_scheme.cart.add_client_item @platinum_item
      visit(new_order_path(:scheme_slug => @user_scheme.scheme.slug))

      within('#order_summary') do
        page.should have_content "Platinum Canon 1D ( 1 )"
        page.should_not have_content "Total"
      end
    end

    scenario "should not display total items and points on order page" do
      @order = Fabricate(:order, :user => @user)
      @order_item = Fabricate(:order_item, :order => @order, :client_item => @platinum_item)

      visit(order_path(:id => @order, :scheme_slug => @order.order_items.first.scheme.slug))

      within('#order_summary') do
        page.should have_content "Platinum Canon 1D ( 1 )"
        page.should_not have_content "Total"
      end
    end

    scenario "should display order details and not display points on my orders page" do
      @order = Fabricate(:order, :user => @user)
      @order_item = Fabricate(:order_item, :order => @order, :client_item => @platinum_item)

      visit(order_index_path(:scheme_slug => @user_scheme.scheme.slug))

      within('.orders') do
        page.should have_content "ORD#{@order_item.id}"
        page.should have_content "Platinum Canon 1D"
        page.should have_content "Order Confirmed"
        page.should_not have_content "600"
      end
    end
  end
end