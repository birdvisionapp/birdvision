require 'request_spec_helper'

feature "Client Manager" do

  before :each do
    @apple = Fabricate(:client, :client_name => "Apple")
    client_manager_admin_user = Fabricate(:client_manager_admin_user)
    apple_client_manager = Fabricate(:client_manager, :client => @apple, :admin_user => client_manager_admin_user)

    login_as client_manager_admin_user, :scope => :admin_user
  end

  scenario "Should list participants only of manager's client" do
    microsoft = Fabricate(:client, :client_name => "Microsoft")
    jobs = Fabricate(:user, :full_name => "Steve Jobs", :client => @apple)
    Fabricate(:user, :full_name => "Bill Gates", :client => microsoft)

    visit(admin_users_path)

    within('.actions') do
      page.should_not have_link 'Upload Participants'
      page.should_not have_link 'Send Activation Link'
      page.should_not have_link 'Inactive Participant(s)'
      page.should_not have_link 'Active Participant(s)'
      page.should have_link 'Download'
    end

    within('.users') do
      page.should have_no_selector("input[type='checkbox']")

      within("#user_#{jobs.id}") do
        page.should have_content "Steve Jobs"
      end
      page.should_not have_content "Bill Gates"
    end
  end

  scenario "Should not show activation link for participant" do
    user = Fabricate(:user, :client => @apple, :reset_password_token => 'bob', :reset_password_sent_at => Time.now)

    visit(admin_user_path(user))

    page.should_not have_content edit_user_password_path(@user)
  end

  scenario "Should list schemes only for manager's client" do
    microsoft = Fabricate(:client, :client_name => "Microsoft")

    big_bang_dhamaka = Fabricate(:scheme, :name => "BBD", :client => @apple)
    small_bang_dhamaka = Fabricate(:scheme, :name => "SBD", :client => microsoft)

    visit(admin_schemes_path)

    within('.actions') do
      page.should_not have_link 'Add New Scheme', new_admin_scheme_path
    end

    within('.schemes') do
      within("#scheme_#{big_bang_dhamaka.id}") do
        page.should have_content big_bang_dhamaka.name
        page.should_not have_link 'Edit', edit_admin_scheme_path(big_bang_dhamaka)
        page.should have_link 'Report', admin_scheme_download_report_path(big_bang_dhamaka, :format => 'csv')
      end
      page.should_not have_content small_bang_dhamaka.name
    end
  end

  scenario "Should display info for manager's client on clients dashboard" do
    microsoft = Fabricate(:client, :client_name => "Microsoft")
    reseller = Fabricate(:reseller)
    Fabricate(:client_reseller, :client => microsoft)

    visit(admin_clients_path)
    within('.clients') do
      page.should_not have_content 'Reseller'

      within("#client_#{@apple.id}") do
        page.should have_content @apple.client_name
        page.should_not have_content reseller.name
        page.should have_link 'Report', admin_client_download_report_path(@apple, format: "csv")
      end

      page.should_not have_content microsoft.client_name
    end
  end


  context "Orders" do
    scenario "Should list orders placed for manager's client" do
      gabbar =Fabricate(:user, :client => Fabricate(:client, :client_name => "sholay"), :participant_id => 'gabbarsingh', :full_name => "Gabbar Singh")
      bbd = Fabricate(:scheme, :name => "BBD", :client => @apple)
      s2 = Fabricate(:item, :title => "samsung s2 black")
      s2_client_item = Fabricate(:client_item, :item => s2, :client_catalog => bbd.client.client_catalog)
      gabbars_order = Fabricate(:order, :user => gabbar)
      order_item = Fabricate(:order_item, :order => gabbars_order, :client_item => s2_client_item, :quantity => 1,
                             :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000,
                             :shipping_code => "123", :shipping_agent => "DHL", :mrp => 5_000,
                             :created_at => Time.now - 20.hours,
                             :status => :new, :scheme => bbd)

      client2 = Fabricate(:client, :client_name => "Client 2")
      sbd = Fabricate(:scheme, :name => "SBD", :client => client2)
      red_table = Fabricate(:item, :title => "Red Table")
      red_table_client_item = Fabricate(:client_item, :item => red_table, :client_catalog => sbd.client.client_catalog)
      Fabricate(:order_item, :client_item => red_table_client_item, :quantity => 1,
                :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :shipping_code => "123",
                :shipping_agent => "DHL", :mrp => 5_000,
                :created_at => Time.now + 20.hours, :status => :sent_to_supplier,
                :scheme => sbd)

      visit(admin_order_items_path)
      within('#filters-content') do
        page.should have_no_selector("#q_client_item_item_category_ancestry_eq")
        page.should have_no_selector("#q_client_item_item_category_id_eq")
        page.should have_no_selector("#q_supplier_id_eq")
      end
      within('.orders') do
        within("#order_item_#{order_item.id}") do
          page.should have_content "samsung s2 black"
          page.should have_no_selector(".status-actions")
          page.should have_no_selector(".tracking-info")
        end
        page.should_not have_content "Red Table"
      end
    end

    scenario "Should download order CSV " do
      Fabricate(:order_item, :client_item => Fabricate(:client_item, :client_catalog => @apple.client_catalog), :quantity => 1,
                :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :shipping_code => "123", :shipping_agent => "DHL", :mrp => 5_000)
      visit(admin_order_items_path(format: "csv"))

      header = ['Order ID', 'Category', 'Sub Category', 'Item Id', 'Item Name', 'Quantity', 'Participant Full Name',
                'Participant Username', 'Recipient name', 'Address', 'Landmark', 'City', 'Pincode', 'State', 'Mobile', 'Landline', 'Client', 'Scheme',
                'Status', 'Dispatched To Participant Date', 'Redeemed At Date', 'Points', 'MRP(Rs.)',
                'Client Price(Rs.)', 'Aging Total', 'Shipping Agent', 'Shipping Code'].join(",")

      page.should have_content(header)
    end
  end

  context "Catalogs" do
    scenario "Should see client catalogs only for manager's client" do
      microsoft = Fabricate(:client, :client_name => "Microsoft")
      samsung = Fabricate(:client_item, :item => Fabricate(:item, :title => "samsung"), :client_catalog => @apple.client_catalog, :client_price => 1_15_001)
      s3 = Fabricate(:client_item, :item => Fabricate(:item, :title => "s3"), :client_catalog => microsoft.client_catalog, :client_price => 1_15_001)

      visit(admin_client_catalog_path(:id => @apple))
      within('.client-catalog') do
        page.should have_content @apple.client_name
        page.should_not have_content microsoft.client_name
      end

      within('.filters') do
        # this is to assert that there no other textbox appearing in the filters apart from the ones mentioned below!
        page.all('input[type="text"]').count.should == 5
        page.all('td').count.should == 3

        page.should have_selector("#q_item_title_cont")
        page.should have_selector("#q_item_preferred_supplier_mrp_gteq")
        page.should have_selector("#q_item_preferred_supplier_mrp_lteq")
        page.should have_selector("#q_client_price_gteq")
        page.should have_selector("#q_client_price_lteq")
      end

      within('.client-catalog-items') do
        page.should_not have_content "Pref. Supplier"
        page.should_not have_content "Channel Price(Rs.)"
        page.should_not have_content "Supplier margin(%)"
        page.should_not have_content "Base Price(Rs.)"
        page.should_not have_content "Base Margin(%)"
        page.should_not have_content "Client Margin(%)"
        page.should_not have_content "Actions"

        within("#client_item_#{samsung.id}") do
          page.should have_content samsung.title
          page.should_not have_content s3.title
          page.should_not have_link 'Edit', admin_client_item_edit_path(:id => samsung.id)
          page.should_not have_link 'Delete', admin_remove_from_client_catalog_path(:id => samsung.client.id, :client_item_id => samsung.id)
        end
      end
    end

    scenario "Should see scheme catalogs only for manager's client" do
      microsoft = Fabricate(:client, :client_name => "Microsoft")
      iphone = Fabricate(:client_item, :item => Fabricate(:item, :title => "iphone"), :client_catalog => @apple.client_catalog, :client_price => 1_15_001)
      office = Fabricate(:client_item, :item => Fabricate(:item, :title => "office"), :client_catalog => microsoft.client_catalog, :client_price => 1_15_001)
      bbd = Fabricate(:scheme, :client => @apple)
      sbd = Fabricate(:scheme, :client => microsoft)
      bbd.catalog.add([iphone])
      sbd.catalog.add([office])

      visit(admin_scheme_catalog_path(bbd))

      within('.filters') do
        # this is to assert that there no other textbox appearing in the filters apart from the ones mentioned below!
        page.all('input[type="text"]').count.should == 5
        page.all('td').count.should == 3

        page.should have_selector("#q_client_item_item_title_cont")
        page.should have_selector("#q_client_item_item_preferred_supplier_mrp_gteq")
        page.should have_selector("#q_client_item_item_preferred_supplier_mrp_lteq")
        page.should have_selector("#q_client_item_client_price_gteq")
        page.should have_selector("#q_client_item_client_price_lteq")
      end

      within(".scheme-catalog-items") do
        page.should_not have_content "Pref. Supplier"
        page.should_not have_content "Channel Price(Rs.)"
        page.should_not have_content "Supplier margin(%)"
        page.should_not have_content "Base Price(Rs.)"
        page.should_not have_content "Base Margin(%)"
        page.should_not have_content "Client Margin(%)"
        page.should_not have_content "Actions"

        within("#client_item_#{iphone.id}") do
          page.should have_content iphone.title
          page.should_not have_content office.title

          page.should_not have_link 'Delete', admin_remove_from_scheme_catalog_path(:id => bbd.id, :client_item_id => iphone.id)
        end
      end
    end

    it "should include only allowed fields in client catalog report " do
      category = Fabricate(:category)
      sub_category_sofa = Fabricate(:sub_category_sofa, :ancestry => category.id)
      Fabricate(:client_item, :item => Fabricate(:item, :category => sub_category_sofa), :client_catalog => @apple.client_catalog)
      visit(admin_client_catalog_path(:id => @apple.id, :format => :csv))
      header = ["Item Id", "Item Name", "Category", "Sub Category", "MRP(Rs.)", "Client Price(Rs.)", "Points", "Schemes"].join(",")
      page.should have_content(header)
    end
  end
  it "should include only allowed fields in level club catalog" do
    scheme = Fabricate(:scheme, :client => @apple)
    platinum_item = Fabricate(:client_item, :item => Fabricate(:item, :title => 'Macbook pro'), :client_catalog => @apple.client_catalog)
    scheme.catalog.add([platinum_item])
    level_club = level_club_for(scheme, 'level1', 'platinum')
    level_club.catalog.add([platinum_item])

    visit(admin_level_club_catalog_path(level_club))
    page.should_not have_content "Average client margin"
    within('.client-catalog-items') do
      page.should_not have_content "Pref. Supplier"
      page.should_not have_content "Channel Price(Rs.)"
      page.should_not have_content "Supplier margin(%)"
      page.should_not have_content "Base Price(Rs.)"
      page.should_not have_content "Base Margin(%)"
      page.should_not have_content "Client Margin(%)"
      page.should_not have_content "Actions"

      within("#client_item_#{platinum_item.id}") do
        page.should have_content platinum_item.title
        page.should_not have_link 'Delete', admin_remove_from_level_club_catalog_path(:id => level_club_for(scheme, 'level1', 'platinum').id, :client_item_id => platinum_item.id)
      end
    end
  end
end

