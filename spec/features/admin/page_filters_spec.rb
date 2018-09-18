require 'request_spec_helper'

feature "Page Filters Spec" do

  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end
  context "order dashboard" do
    scenario "Should filter order items" do

      gabbar =Fabricate(:user, :client => Fabricate(:client, :client_name => "sholay"), :participant_id => 'gabbarsingh', :full_name => "Gabbar Singh")
      client = Fabricate(:client, :client_name => "Client 1")
      bbd = Fabricate(:scheme, :name => "BBD", :client => client)
      flipkart = Fabricate(:supplier, :name => "Flipkart")
      category1 = Fabricate(:category, :title => "Electronics")
      sub_category1 = Fabricate(:category, :title => "Mobile", :ancestry => category1.id)
      s2 = Fabricate(:item, :title => "samsung s2 black", :category => sub_category1)
      Fabricate(:item_supplier, :item => s2, :mrp => 31_123, :channel_price => 18_000, :supplier => flipkart)
      s2_client_item = Fabricate(:client_item, :item => s2, :client_catalog => bbd.client.client_catalog)
      gabbars_order = Fabricate(:order, :user => gabbar)
      order_item = Fabricate(:order_item, :order => gabbars_order, :client_item => s2_client_item, :quantity => 1,
                             :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000,
                             :shipping_code => "123", :shipping_agent => "DHL", :mrp => 5_000,
                             :supplier_id => flipkart.id, :created_at => Time.now - 20.hours,
                             :status => :new, :scheme => bbd)

      client2 = Fabricate(:client, :client_name => "Client 2")
      sbd = Fabricate(:scheme, :name => "SBD", :client => client2)
      infibeam = Fabricate(:supplier, :name => "Infibeam")
      category2 = Fabricate(:category, :title => "Home Appliances")
      sub_category2 = Fabricate(:category, :title => "Table", :ancestry => category2.id)
      red_table = Fabricate(:item, :title => "Red Table", :category => sub_category2)
      Fabricate(:item_supplier, :item => red_table, :mrp => 31_123, :channel_price => 18_000, :supplier => infibeam)
      red_table_client_item = Fabricate(:client_item, :item => red_table, :client_catalog => sbd.client.client_catalog)
      Fabricate(:order_item, :client_item => red_table_client_item, :quantity => 1,
                :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :shipping_code => "123",
                :shipping_agent => "DHL", :mrp => 5_000, :supplier_id => infibeam.id,
                :created_at => Time.now + 20.hours, :status => :sent_to_supplier,
                :scheme => sbd)

      visit(admin_order_items_path)
      fill_in("Item Name", :with => "s2")
      fill_in("Order ID", :with => order_item.order.id)
      select("Electronics", :from => "q_client_item_item_category_ancestry_eq")
      select("Mobile", :from => "q_client_item_item_category_id_eq")
      select("Flipkart", :from => "q_supplier_id_eq")
      select("New", :from => "q_status_eq")
      select("BBD", :from => "q_scheme_id_eq")
      select("Client 1", :from => "q_scheme_client_id_eq")
      fill_in('q_created_at_date_gteq', :with => Date.yesterday.strftime("%d-%m-%Y"))
      fill_in('q_created_at_date_lteq', :with => Date.today.strftime("%d-%m-%Y"))
      fill_in("Username", :with => gabbar.username)
      fill_in("Full Name", :with => gabbar.full_name)

      click_on "Filter"
      within("#order_item_#{order_item.id}") do
        page.should have_content "samsung s2 black"
      end
      within('.orders') do
        page.should_not have_content "Red Table"
      end
    end
  end


  context "participant dashboard" do
    scenario "Should filter participants" do
      emerson = Fabricate(:client, :client_name => "Emerson")
      axis = Fabricate(:client, :client_name => "Axis")
      yesterday = Date.yesterday
      bbd = Fabricate(:scheme, :name => "BBD", :client => emerson, :created_at => yesterday)
      sbd = Fabricate(:scheme, :name => "SBD", :client => axis, :created_at => yesterday)
      jay = Fabricate(:user, :full_name => "Jay Praji", :participant_id => 2, :created_at => yesterday, :client => emerson,
                      :email => "jay@sholay.in", :activation_status => User::ActivationStatus::NOT_ACTIVATED)
      Fabricate(:user_scheme, :user => jay, :scheme => bbd)
      viru = Fabricate(:user, :full_name => "Viru Praji", :participant_id => 4, :created_at => Time.now, :client => emerson)
      Fabricate(:user_scheme, :user => viru, :scheme => sbd)

      visit(admin_users_path)
      fill_in("Full Name", :with => "Jay Praji")
      fill_in("Email", :with => "jay@sholay.in")
      fill_in("Username", :with => "emerson.2")
      fill_in("Participant ID", :with => "2")
      select("Emerson", :from => "q_client_id_eq")
      select("BBD", :from => "q_user_schemes_scheme_id_eq")
      fill_in('q_created_at_date_gteq', :with => (yesterday.to_date).strftime("%d-%m-%Y"))
      fill_in('q_created_at_date_lteq', :with => Date.today.strftime("%d-%m-%Y"))
      select(User::ActivationStatus::NOT_ACTIVATED, :from => 'q_activation_status_eq')
      click_on "Filter"
      within("#user_#{jay.id}") do
        page.should have_content "Jay"
      end
      within('.users') do
        page.should_not have_content "Viru"
      end
    end

    scenario "Should retain filters after activating participants on participants dashboard Page" do
      emerson = Fabricate(:client, :client_name => "Emerson")
      axis = Fabricate(:client, :client_name => "Axis")
      yesterday = Date.yesterday
      bbd = Fabricate(:scheme, :name => "BBD", :client => emerson, :created_at => yesterday)
      sbd = Fabricate(:scheme, :name => "SBD", :client => axis, :created_at => yesterday)
      jay = Fabricate(:user, :full_name => "Jay Praji", :participant_id => 2, :created_at => yesterday, :client => emerson,
                      :email => "jay@sholay.in", :activation_status => User::ActivationStatus::NOT_ACTIVATED)
      Fabricate(:user_scheme, :user => jay, :scheme => bbd)
      viru = Fabricate(:user, :full_name => "Viru Praji", :participant_id => 4, :created_at => Time.now, :client => emerson)
      Fabricate(:user_scheme, :user => viru, :scheme => sbd)

      visit(admin_users_path)
      find("#filters-opener").click
      fill_in("Full Name", :with => "Jay Praji")
      click_on "Filter"
      within("#user_#{jay.id}") do
        find(".user_checkbox").set(true)
      end
      click_on 'Send Activation Link'
      within('.users') do
        page.should_not have_content "Viru"
      end
    end

    scenario "Should retain filters after active participants on participants dashboard Page" do
      emerson = Fabricate(:client, :client_name => "Emerson")
      axis = Fabricate(:client, :client_name => "Axis")
      yesterday = Date.yesterday
      bbd = Fabricate(:scheme, :name => "BBD", :client => emerson, :created_at => yesterday)
      sbd = Fabricate(:scheme, :name => "SBD", :client => axis, :created_at => yesterday)
      jay = Fabricate(:user, :full_name => "Jay Praji", :participant_id => 2, :created_at => yesterday, :client => emerson,
                      :email => "jay@sholay.in", :status => User::Status::ACTIVE)
      Fabricate(:user_scheme, :user => jay, :scheme => bbd)
      viru = Fabricate(:user, :full_name => "Viru Praji", :participant_id => 4, :created_at => Time.now, :client => emerson)
      Fabricate(:user_scheme, :user => viru, :scheme => sbd)

      visit(admin_users_path)
      find("#filters-opener").click
      fill_in("Full Name", :with => "Jay Praji")
      click_on "Filter"
      within("#user_#{jay.id}") do
        find(".user_checkbox").set(true)
      end
      click_on 'Active Participant(s)'
      within('.users') do
        page.should_not have_content "Viru"
        page.should have_content "Jay"
      end
    end

    scenario "Should retain filters after inactive participants on participants dashboard Page" do
      emerson = Fabricate(:client, :client_name => "Emerson")
      axis = Fabricate(:client, :client_name => "Axis")
      yesterday = Date.yesterday
      bbd = Fabricate(:scheme, :name => "BBD", :client => emerson, :created_at => yesterday)
      sbd = Fabricate(:scheme, :name => "SBD", :client => axis, :created_at => yesterday)
      jay = Fabricate(:user, :full_name => "Jay Praji", :participant_id => 2, :created_at => yesterday, :client => emerson,
                      :email => "jay@sholay.in", :status => User::Status::INACTIVE)
      Fabricate(:user_scheme, :user => jay, :scheme => bbd)
      viru = Fabricate(:user, :full_name => "Viru Praji", :participant_id => 4, :created_at => Time.now, :client => emerson)
      Fabricate(:user_scheme, :user => viru, :scheme => sbd)

      visit(admin_users_path)
      find("#filters-opener").click
      fill_in("Full Name", :with => "Jay Praji")
      click_on "Filter"
      within("#user_#{jay.id}") do
        find(".user_checkbox").set(true)
      end
      click_on 'Inactive Participant(s)'
      within('.users') do
        page.should_not have_content "Viru"
        page.should have_content "Jay"
      end
    end

  end

  context "Draft items dashboard" do
    scenario "Should filter draft items" do
      flipkart = Fabricate(:supplier, :name => "Flipkart")
      infibeam = Fabricate(:supplier, :name => "Infibeam")

      electronics = Fabricate(:category, :title => 'Electronics')
      mobile = Fabricate(:category, :title => 'Mobile', :ancestry => electronics.id)
      s3 = Fabricate(:draft_item, :title => "samsung s3", :supplier => flipkart, :mrp => 30_000, :channel_price => 20_000, :category => mobile,
                     :model_no => "1234")

      home_appliances = Fabricate(:category, :title => 'Home appliances')
      chair = Fabricate(:category, :title => 'Chair', :ancestry => home_appliances.id)
      red_chair = Fabricate(:draft_item, :title => "red chair", :supplier => infibeam, :mrp => 10_000, :channel_price => 2_000, :category => chair)

      visit(admin_draft_items_path)
      fill_in("Item Name", :with => "s3")
      fill_in("Model No.", :with => "123")
      select("Electronics", :from => "q_category_ancestry_eq")
      select("Mobile", :from => "q_category_id_eq")
      select("Flipkart", :from => "q_supplier_id_eq")
      click_on "Filter"
      within("#draft_item_#{s3.id}") do
        page.should have_content "samsung s3"
      end
      within('.draft_items') do
        page.should_not have_content "red chair"
      end
    end
  end

  context "Master catalog dashboard" do
    scenario "Should filter items" do
      flipkart = Fabricate(:supplier, :name => "Flipkart")
      category1 = Fabricate(:category, :title => "Electronics")
      sub_category1 = Fabricate(:category, :title => "Mobile", :ancestry => category1.id)
      s2 = Fabricate(:item, :title => "samsung s2 black", :category => sub_category1, :bvc_price => 27_000, :model_no => "12345")
      item_supplier1 = Fabricate(:item_supplier, :item => s2, :mrp => 31_123, :channel_price => 18_000, :supplier => flipkart, :is_preferred => true)
      item_supplier1.save!


      infibeam = Fabricate(:supplier, :name => "Infibeam")
      category2 = Fabricate(:category, :title => "Home Appliances")
      sub_category2 = Fabricate(:category, :title => "Table", :ancestry => category2.id)
      red_table = Fabricate(:item, :title => "Red Table", :category => sub_category2, :bvc_price => 30_000)
      item_supplier2 = Fabricate(:item_supplier, :item => red_table, :mrp => 35_000, :channel_price => 20_000, :supplier => infibeam, :is_preferred => true)
      item_supplier2.save!

      visit(admin_master_catalog_index_path)
      fill_in("Item Name", :with => "s2")
      fill_in("Item Id", :with => s2.id)
      fill_in("Model No.", :with => "123")
      select("Flipkart", :from => "q_preferred_supplier_supplier_id_eq")
      fill_in('q_preferred_supplier_channel_price_gteq', :with => "17000")
      fill_in('q_preferred_supplier_channel_price_lteq', :with => "19000")

      fill_in('q_preferred_supplier_mrp_gteq', :with => "15000")
      fill_in('q_preferred_supplier_mrp_lteq', :with => "35000")

      #fill_in('q_preferred_supplier_supplier_margin_gteq', :with => "17000")
      #fill_in('q_preferred_supplier_supplier_margin_lteq', :with => "19000")

      fill_in('q_bvc_price_gteq', :with => "25000")
      fill_in('q_bvc_price_lteq', :with => "39000")

      fill_in('q_margin_gteq', :with => "236")
      fill_in('q_margin_lteq', :with => "240")
      click_on "Filter"
      within("#item_#{s2.id}") do
        page.should have_content "samsung s2 black"
      end
      within('.master_catalog') do
        page.should_not have_content "Red Table"
      end
    end
  end

  context "Client catalog dashboard" do
    scenario "Should filter items on edit" do
      client = Fabricate(:client)
      flipkart = Fabricate(:supplier, :name => "Flipkart")
      category1 = Fabricate(:category, :title => "Electronics")
      sub_category1 = Fabricate(:category, :title => "Mobile", :ancestry => category1.id)
      s2 = Fabricate(:item, :title => "samsung s2 black", :category => sub_category1, :bvc_price => 27_000, :model_no => "1234")
      item_supplier1 = Fabricate(:item_supplier, :item => s2, :mrp => 31_123, :channel_price => 18_000, :supplier => flipkart, :is_preferred => true)
      item_supplier1.save!


      infibeam = Fabricate(:supplier, :name => "Infibeam")
      category2 = Fabricate(:category, :title => "Home Appliances")
      sub_category2 = Fabricate(:category, :title => "Table", :ancestry => category2.id)
      red_table = Fabricate(:item, :title => "Red Table", :category => sub_category2, :bvc_price => 30_000)
      item_supplier2 = Fabricate(:item_supplier, :item => red_table, :mrp => 35_000, :channel_price => 20_000, :supplier => infibeam, :is_preferred => true)
      item_supplier2.save!

      visit(edit_admin_client_catalog_path(:id => client.id))
      fill_in("Item Name", :with => "s2")
      fill_in("Item Id", :with => s2.id)
      fill_in("Model No.", :with => "123")

      select("Flipkart", :from => "q_preferred_supplier_supplier_id_eq")
      fill_in('q_preferred_supplier_channel_price_gteq', :with => "17000")
      fill_in('q_preferred_supplier_channel_price_lteq', :with => "19000")

      fill_in('q_preferred_supplier_mrp_gteq', :with => "15000")
      fill_in('q_preferred_supplier_mrp_lteq', :with => "35000")

      #fill_in('q_preferred_supplier_supplier_margin_gteq', :with => "17000")
      #fill_in('q_preferred_supplier_supplier_margin_lteq', :with => "19000")

      fill_in('q_bvc_price_gteq', :with => "25000")
      fill_in('q_bvc_price_lteq', :with => "39000")

      fill_in('q_margin_gteq', :with => "236")
      fill_in('q_margin_lteq', :with => "240")
      click_on "Filter"
      within("#item_#{s2.id}") do
        page.should have_content "samsung s2 black"
      end
      within('.master_catalog') do
        page.should_not have_content "Red Table"
      end
    end

    scenario "Should filter client items in list view" do
      client = Fabricate(:client)
      flipkart = Fabricate(:supplier, :name => "Flipkart")
      category1 = Fabricate(:category, :title => "Electronics")
      sub_category1 = Fabricate(:category, :title => "Mobile", :ancestry => category1.id)
      s2 = Fabricate(:item, :title => "samsung s2 black", :category => sub_category1, :bvc_price => 27_000)
      item_supplier1 = Fabricate(:item_supplier, :item => s2, :mrp => 31_123, :channel_price => 18_000, :supplier => flipkart, :is_preferred => true)
      item_supplier1.save!
      s2_client_item = Fabricate(:client_item, :client_catalog => client.client_catalog, :client_price => 30_000, :item => s2)

      infibeam = Fabricate(:supplier, :name => "Infibeam")
      category2 = Fabricate(:category, :title => "Home Appliances")
      sub_category2 = Fabricate(:category, :title => "Table", :ancestry => category2.id)
      red_table = Fabricate(:item, :title => "Red Table", :category => sub_category2, :bvc_price => 30_000)
      item_supplier2 = Fabricate(:item_supplier, :item => red_table, :mrp => 35_000, :channel_price => 20_000, :supplier => infibeam, :is_preferred => true)
      item_supplier2.save!
      red_table_client_item = Fabricate(:client_item, :client_catalog => client.client_catalog, :client_price => 34_000, :item => red_table)

      visit(admin_client_catalog_path(:id => client.id))
      select("Flipkart", :from => "q_item_preferred_supplier_supplier_id_eq")
      fill_in("Item Name", :with => "s2")
      fill_in('q_item_preferred_supplier_channel_price_gteq', :with => "17000")
      fill_in('q_item_preferred_supplier_channel_price_lteq', :with => "19000")

      fill_in('q_item_preferred_supplier_mrp_gteq', :with => "15000")
      fill_in('q_item_preferred_supplier_mrp_lteq', :with => "35000")

      #fill_in('q_preferred_supplier_supplier_margin_gteq', :with => "17000")
      #fill_in('q_preferred_supplier_supplier_margin_lteq', :with => "19000")

      fill_in('q_item_bvc_price_gteq', :with => "25000")
      fill_in('q_item_bvc_price_lteq', :with => "39000")

      fill_in('q_item_margin_gteq', :with => "236")
      fill_in('q_item_margin_lteq', :with => "240")

      fill_in('q_client_price_gteq', :with => "29000")
      fill_in('q_client_price_lteq', :with => "31000")

      click_on "Filter"
      within("#client_item_#{s2_client_item.id}") do
        page.should have_content "samsung s2 black"
      end
      within('.client-catalog-items') do
        page.should_not have_content "Red Table"
      end
    end
  end

  context "Scheme catalog dashboard" do
    scenario "Should filter client items on edit" do
      client = Fabricate(:client)
      bbd = Fabricate(:scheme, :name => "BBD", :client => client)

      flipkart = Fabricate(:supplier, :name => "Flipkart")
      category1 = Fabricate(:category, :title => "Electronics")
      sub_category1 = Fabricate(:category, :title => "Mobile", :ancestry => category1.id)
      s2 = Fabricate(:item, :title => "samsung s2 black", :category => sub_category1, :bvc_price => 27_000)
      item_supplier1 = Fabricate(:item_supplier, :item => s2, :mrp => 31_123, :channel_price => 18_000, :supplier => flipkart, :is_preferred => true)

      infibeam = Fabricate(:supplier, :name => "Infibeam")
      category2 = Fabricate(:category, :title => "Home Appliances")
      sub_category2 = Fabricate(:category, :title => "Table", :ancestry => category2.id)
      red_table = Fabricate(:item, :title => "Red Table", :category => sub_category2, :bvc_price => 30_000)
      item_supplier2 = Fabricate(:item_supplier, :item => red_table, :mrp => 35_000, :channel_price => 20_000, :supplier => infibeam, :is_preferred => true)

      s2_client_item = Fabricate(:client_item, :item => s2, :client_catalog => bbd.client.client_catalog, :client_price => 31_000)
      red_table_client_item = Fabricate(:client_item, :item => red_table, :client_catalog => bbd.client.client_catalog, :client_price => 34_000)

      visit(edit_admin_scheme_catalog_path(:id => bbd.id))
      select("Flipkart", :from => "q_item_preferred_supplier_supplier_id_eq")
      fill_in("Item Name", :with => "s2")
      fill_in('q_item_preferred_supplier_channel_price_gteq', :with => "17000")
      fill_in('q_item_preferred_supplier_channel_price_lteq', :with => "19000")

      fill_in('q_item_preferred_supplier_mrp_gteq', :with => "30000")
      fill_in('q_item_preferred_supplier_mrp_lteq', :with => "32000")

      fill_in('q_item_bvc_price_gteq', :with => "26000")
      fill_in('q_item_bvc_price_lteq', :with => "38000")

      fill_in('q_client_price_gteq', :with => "29000")
      fill_in('q_client_price_lteq', :with => "31000")

      click_on "Filter"
      within("#client_item_#{s2_client_item.id}") do
        page.should have_content "samsung s2 black"
      end
      within('.client-catalog-items') do
        page.should_not have_content "Red Table"
      end
    end
  end
end

