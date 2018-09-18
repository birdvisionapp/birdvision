require 'request_spec_helper'


feature "Carts Spec" do
  before :each do
    @user = Fabricate(:user)
    login_as @user
  end

  context "View cart" do
    before :each do
      category = Fabricate(:category)
      @sub_category = Fabricate(:category, :ancestry => category.id)
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
    end
    scenario "should display item information in cart for a scheme" do
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :category => @sub_category))
      new_user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :name => "new scheme name", :client => @user.client))
      cart = @user_scheme.cart
      @user_scheme.scheme.client_items << client_item
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])

      2.times { cart.add_client_item(client_item) }
      visit(catalog_path_for(@user_scheme))
      click_link("View cart")

      [client_item.item.title, client_item.item.description, "90,000", "1,80,000", cart.cart_items.first.quantity].each do |value|
        within("##{client_item.slug}") do
          page.should have_content value
        end
      end
      within("##{client_item.slug}") do
        page.should have_selector("img[src$='#{client_item.item.image.url}']")
      end

      within('.cart-total-points') do
        page.should have_content("Grand Total : 1,80,000 pts")
      end

      visit(catalog_path_for(new_user_scheme))
      click_link("View cart")
      within(".alert") do
        page.should have_content("Your cart is empty")
      end
    end

    context "redemption" do
      before do
        @cart = @user_scheme.cart
      end

      scenario "should not allow users to redeem if scheme redemption is not yet active" do
        past_scheme = Fabricate(:not_yet_started_scheme, :name => 'Past scheme', :client => @user.client)
        user_scheme = Fabricate(:user_scheme, :scheme => past_scheme, :user => @user)
        client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 12_0, :item => Fabricate(:item, :category => @sub_category))
        past_scheme.client_items = [client_item]
        level_club_for(past_scheme, 'level1', 'platinum').catalog.add([client_item])

        user_scheme.cart.add_client_item(client_item)

        visit(carts_path(:scheme_slug => past_scheme.slug))
        find(".btn-disabled")['disabled'].should be_true
      end

      scenario "should not allow users to redeem when cart total exceeds user points" do
        client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 1_20_000, :item => Fabricate(:item, :category => @sub_category))
        @user_scheme.scheme.client_items << client_item
        level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])
        visit(catalog_path_for(@user_scheme))
        @cart.add_client_item(client_item)

        visit(carts_path(:scheme_slug => @user_scheme.scheme.slug))

        page.should have_content "You need #{@cart.total_points - @user.total_redeemable_points} more points to redeem everything in your cart. Kindly remove a few items to continue redeeming"
        page.should_not have_button("Redeem Cart")
      end

      scenario "should allow users to redeem when cart total is less than user points" do
        client_item1 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog,
                                 :client_price => 13_000,
                                 :item => Fabricate(:item, :category => @sub_category))
        client_item2 = Fabricate(:client_item, :client_catalog => @user.client.client_catalog,
                                 :client_price => 13_000,
                                 :item => Fabricate(:item, :category => @sub_category))

        @user_scheme.scheme.client_items = [client_item1, client_item2]
        level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item1, client_item2])

        visit(catalog_path_for(@user_scheme))
        within("#item_id_#{client_item1.id}") do
          click_on 'Add to cart'
        end
        click_on 'Add more to cart'
        within("#item_id_#{client_item2.id}") do
          click_on 'Add to cart'
        end
        visit(carts_path(:scheme_slug => @user_scheme.scheme.slug))
        within("##{client_item1.slug}") do
          click_button "Remove"
        end
        page.should_not have_content "You need #{@user_scheme.cart.total_points - @user.total_redeemable_points} more points to redeem everything in your cart. Kindly remove a few items to continue redeeming"
        page.should have_button("Redeem")
      end
    end

    context "update quantity" do
      scenario "should allow user to update quantity of item" do
        client_item = Fabricate(:client_item, :client_price => 2_000)
        cart_item = Fabricate(:cart_item, :client_item => client_item, :cart => @user_scheme.cart)
        @user_scheme.scheme.client_items << client_item
        level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])
        visit (carts_path(:scheme_slug => @user_scheme.scheme.slug))

        within ("##{cart_item.client_item.slug}") do
          find(".quantity").should have_content("1")

          click_on("change")
          fill_in("#{cart_item.client_item.slug}_quantity", :with => '3')
          click_on("save")
        end

        within ("##{cart_item.client_item.slug}") do
          find(".change-quantity-form .item-quantity").value.should == "3"
          find(".sub-total").should have_content("60,000")
        end

        within(".shopping-cart .footer") do
          page.should have_content("60,000")
        end
      end

      scenario "should complain for invalid update of quantity of item" do
        client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :client_price => 2_000)
        @user_scheme.scheme.client_items << client_item
        level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])
        cart_item = Fabricate(:cart_item, :client_item => client_item, :cart => @user_scheme.cart)

        visit (carts_path(:scheme_slug => @user_scheme.scheme.slug))

        within ("##{cart_item.client_item.slug}") do
          click_on("change")
          fill_in("#{cart_item.client_item.slug}_quantity", :with => '-3')
          click_on("save")
        end

        within ("##{cart_item.client_item.slug}") do
          find(".change-quantity-form .item-quantity").value.should == "1"
          find(".sub-total").should have_content("20,000")
        end

        within(".alert") do
          page.should have_content("Please enter valid quantity")
        end
        within(".shopping-cart .footer") do
          page.should have_content("20,000")
        end

      end
    end

    scenario "should display item details page on clicking item link" do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :category => sub_category))
      @user_scheme.scheme.client_items = [client_item]
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])

      visit(catalog_path_for(@user_scheme))
      cart = @user_scheme.cart
      cart.add_client_item(client_item)
      visit(carts_path(:scheme_slug => @user_scheme.scheme.slug))
      click_on(client_item.item.title)
      page.should have_content client_item.item.title
      page.should have_css ".action-container"
    end

    scenario "should return to home page when continue shopping is clicked" do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :category => sub_category))
      scheme = @user_scheme.scheme
      scheme.catalog.add([client_item])
      scheme.level_clubs.first.catalog.add([client_item])

      visit(catalog_path_for(@user_scheme))
      within(".level1-platinum") do
        click_on(client_item.item.title)
      end
      click_link("Add to cart")
      current_path.should == carts_path(:scheme_slug => @user_scheme.scheme.slug)
      click_on("Add more to cart")
      current_path.should == catalog_path_for(@user_scheme)
    end
  end

  context "Add to cart" do
    before :each do
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
    end

    scenario "should allow users add an item to cart from items details page" do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :title => "Samsung Galaxy S2", :category => sub_category))
      scheme = @user_scheme.scheme
      scheme.catalog.add([client_item])
      scheme.level_clubs.first.catalog.add([client_item])

      visit(catalog_path_for(@user_scheme))
      within(".level1-platinum") do
        page.find("##{client_item.item.id}_image").click
      end
      click_on("Add to cart")

      current_path.should == carts_path(:scheme_slug => @user_scheme.scheme.slug)
      within("#samsung-galaxy-s2") do
        page.should have_content(client_item.item.title)
        page.should have_content(client_item.item.description)
      end
    end

    scenario "should allow users add an item to cart from search result page" do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :title => "Samsung Galaxy S2", :category => sub_category))
      scheme = @user_scheme.scheme
      scheme.catalog.add([client_item])
      scheme.level_clubs.first.catalog.add([client_item])
      Sunspot.index! client_item

      visit(catalog_path_for(@user_scheme))
      fill_in("search_keyword", :with => 's2')
      find("#searchForm .btn").click

      within("#item_id_#{client_item.item.id}") do
        click_link "Add to cart"
      end

      current_path.should == carts_path(:scheme_slug => scheme.slug)
      within("#samsung-galaxy-s2") do
        page.should have_content(client_item.item.title)
        page.should have_content(client_item.item.description)
      end
    end

    scenario "should allow users add an item to cart from item index page" do
      category = Fabricate(:category)
      sub_category = Fabricate(:sub_category_sofa, :ancestry => category.id)
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog, :item => Fabricate(:item, :title => "Samsung Galaxy S2", :category => sub_category))
      scheme = @user_scheme.scheme
      scheme.catalog.add([client_item])
      scheme.level_clubs.first.catalog.add([client_item])
      visit(catalog_path_for(@user_scheme))

      within("#item_id_#{client_item.item.id}") do
        click_link "Add to cart"
      end

      current_path.should == carts_path(:scheme_slug => scheme.slug)
      within("#samsung-galaxy-s2") do
        page.should have_content(client_item.item.title)
        page.should have_content(client_item.item.description)
      end
    end
  end

  context "Remove from cart" do
    before :each do
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
    end

    scenario "should remove items from cart" do
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog)
      scheme = @user_scheme.scheme
      scheme.catalog.add([client_item])
      scheme.level_clubs.first.catalog.add([client_item])
      cart = @user_scheme.cart
      cart.add_client_item(client_item)
      visit(carts_path(:scheme_slug => @user_scheme.scheme.slug))
      within("##{client_item.slug}") do
        page.should have_content "camera"
        click_button "Remove"
      end
      page.html.should_not have_content "camera"
      page.html.should have_content "Your cart is empty"
    end

    scenario "should show only cart empty message if user removes last item from cart" do
      cart = @user_scheme.cart
      client_item = Fabricate(:client_item, :client_catalog => @user.client.client_catalog)
      @user_scheme.scheme.client_items << client_item
      level_club_for(@user_scheme.scheme, 'level1', 'platinum').catalog.add([client_item])
      cart_item = Fabricate(:cart_item, :cart => cart, :client_item => client_item)

      visit(carts_path(:scheme_slug => @user_scheme.scheme.slug))
      within('#siteContent') do
        click_button "Remove"
        page.should have_content "Your cart is empty"
        page.should_not have_content "#{cart_item.client_item.item.title} has been removed from your cart"
      end
    end
  end

  context "Empty cart" do
    before :each do
      @user_scheme = Fabricate(:user_scheme, :user => @user, :scheme => Fabricate(:scheme, :client => @user.client))
    end
    scenario "should display continue shopping button" do
      visit(carts_path(:scheme_slug => @user_scheme.scheme.slug))
      page.should have_link("Add more to cart")
    end

    scenario "should not display cart item block" do
      visit(carts_path(:scheme_slug => @user_scheme.scheme.slug))
      within('#siteContent') do
        page.should have_no_selector(".shopping-cart")
        page.should_not have_content("Grand Total")
        page.should_not have_button("Redeem Cart")
      end
    end
  end
end

