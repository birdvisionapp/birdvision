require 'request_spec_helper'

feature "Admin - Orders Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  scenario "Should render Order Items Page" do
    visit(admin_order_items_path)
    within("h1") do
      page.should have_content "Orders"
    end

    within("#mainNavigation") do
      page.find("a.active").should have_content("Orders")
    end
  end

  scenario "Should display all orders" do
    order_item = Fabricate(:order_item)
    visit(admin_order_items_path)
    within(".orders") do
      ["Order ID", "Item Name", "Quantity", "User", "Contact Details", "City", "Pin Code", "Status", "Placed On", "Aging", "Actions"].each { |header|
        page.should have_content(header)
      }
      page.should have_content(order_item.order.order_id)
      page.should have_content(order_item.client_item.item.title)
      page.should have_content(order_item.order.user.full_name)
      page.should have_content(order_item.order.user.username)
      page.should have_content(order_item.order.address_name)
      page.should have_content(order_item.order.address_body)
      page.should have_content(order_item.order.address_city)
      page.should have_content(order_item.order.address_state)
      page.should have_content(order_item.order.address_zip_code)
      page.should have_content(order_item.order.address_phone)
      page.should have_content(order_item.order.address_landmark)
      page.should have_content(order_item.order.address_landline_phone)
      page.should have_content(order_item.created_at.to_date.to_formatted_s(:long_ordinal))
      page.should have_content(order_item.status.humanize)
    end
  end

  scenario "Should have download csv link" do
    Fabricate(:order_item)
    visit(admin_order_items_path)
    page.should have_link("Download")
  end

  scenario "Should download order CSV when no filter is applied" do
    flipkart = Fabricate(:supplier, :name => "flipkart")
    s2 = Fabricate(:item, :title => "samsung s2 black")
    order_item = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => s2), :quantity => 1,
                           :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :shipping_code => "123", :shipping_agent => "DHL", :mrp => 5_000, :supplier_id => flipkart.id)
    client_reseller = Fabricate(:client_reseller, :client => order_item.order.user.client, :payout_start_date => Date.yesterday)
    visit(admin_order_items_path(format: "csv"))

    verify_headers()
    verify_order_details_in_report(order_item, client_reseller.reseller.name)
  end

  scenario "Should download only filtered set in order CSV when some filter is applied" do
    flipkart = Fabricate(:supplier, :name => "flipkart")
    infibeam = Fabricate(:supplier, :name => "infibeam")
    s2 = Fabricate(:item, :title => "samsung s2 black")
    Fabricate(:item_supplier, :item => s2, :mrp => 30_000, :channel_price => 18_000, :supplier => flipkart)
    s3 = Fabricate(:item, :title => "S3")
    Fabricate(:item_supplier, :item => s3, :mrp => 30_000, :channel_price => 18_000, :supplier => infibeam)
    mac = Fabricate(:item, :title => "macbook pro")
    Fabricate(:item_supplier, :item => mac, :mrp => 1_30_000, :channel_price => 1_80_000, :supplier => flipkart)

    order_item_1 = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => s2), :created_at => Time.now - 2.days, :quantity => 1,
                             :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :mrp => 5_000, :supplier_id => flipkart.id, :shipping_code => "123", :shipping_agent => "DHL")
    order_item_2 = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => s3), :created_at => Time.now - 2.days, :quantity => 1,
                             :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :mrp => 5_000, :supplier_id => infibeam.id, :shipping_code => "34567", :shipping_agent => "DHL")
    order_item_3 = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => mac), :quantity => 1, :created_at => Time.now - 2.days, :quantity => 1,
                             :channel_price => 1_80_000, :bvc_price => 1_60_000, :price_in_rupees => 1_70_000, :mrp => 1_90_000, :supplier_id => flipkart.id, :shipping_code => "12212", :shipping_agent => "DHL")

    visit(admin_order_items_path(format: "csv", :q => {:supplier_id_eq => flipkart.id}))

    verify_headers()
    [order_item_1, order_item_3].each do |order_item|
      verify_order_details_in_report(order_item)
    end
    page.should_not have_content order_item_2.client_item.item.title
  end


  scenario "should allow admin to change status of order item" do
    Fabricate(:order_item, :created_at => Time.now - 20.hours, :status => :new)

    visit(admin_order_items_path)

    page.find('.status').should have_content("New")
    page.find("td.tracking-info").should_not have_link "Update tracking info."

    within('td.status-actions') do
      click_on('Send to supplier')
    end

    page.find('.status').should have_content("Sent to supplier")
    page.find("td.tracking-info").should have_link "Update tracking info."
    within('td.status-actions') do
      click_on('Send for delivery')
    end


    page.find('.status').should have_content("Delivery in progress")
    page.find("td.tracking-info").should have_link "Update tracking info."
    within('td.status-actions') do
      page.should_not have_link('Dispatched to supplier')
      page.should have_link('Deliver')
      page.should have_link('Incorrect')

      click_on('Deliver')
    end

    page.find('.status').should have_content("Delivered")
    page.find("td.tracking-info").should_not have_link "Update tracking info."
    within('td.status-actions') do
      page.should_not have_link('Deliver')
      page.should_not have_link('Incorrect')
    end

  end
  scenario "should allow to mark orders as incorrect and then refund" do
    user_scheme = Fabricate(:user_scheme, :scheme => Fabricate(:scheme_3x3), :total_points => 10_000, :redeemed_points => 5_000)
    order_item = Fabricate(:order_item, :scheme => user_scheme.scheme,
                               :order => Fabricate(:order, :user => user_scheme.user),
                               :quantity => 2, :status => :new, :price_in_rupees => 10_000,
                               :points_claimed => 2_000)

    visit(admin_order_items_path)
    page.find('.status').should have_content("New")
    within('td.status-actions') do
      click_on('Incorrect')
    end

    page.find('.status').should have_content("Incorrect")
    within('td.status-actions') do
      click_on('Refund')
    end

    page.find('.status').should have_content("Refunded")
  end
end

def verify_order_details_in_report(order_item, reseller_name = nil)
  order = order_item.order
  item = order_item.client_item.item
  data_values = ["ORD#{order_item.order_id}",
                 order_item.parent_category,
                 item.category.title,
                 item.id,
                 item.title,
                 item.preferred_supplier.listing_id,
                 Supplier.find(order_item.supplier_id).name,
                 order_item.quantity,
                 order.user.full_name,
                 order.user.username,
                 order.address_name,
                 order.address_body,
                 order.address_landmark,
                 order.address_city,
                 order.address_zip_code,
                 order.address_state,
                 order.address_phone,
                 order.address_landline_phone,
                 order.user.client_name,
                 order_item.scheme.name,
                 order_item.status_for_report,
                 order_item.dispatched_to_participant_date=="" ? "" : order_item.dispatched_to_participant_date.strftime("%d-%b-%Y"),
                 order_item.created_at.strftime("%d-%b-%Y"),
                 order_item.points_claimed,
                 order_item.mrp,
                 order_item.supplier_margin,
                 order_item.channel_price,
                 order_item.price_in_rupees,
                 order_item.bvc_margin,
                 order_item.price_in_rupees/order_item.quantity,
                 order_item.client_margin,
                 order_item.distance_of_time_in_words,
                 "DHL",
                 "123",
                 reseller_name].compact

  data_values.each { |data|
    page.should have_content(data)
  }
end

def verify_headers
  headers = ["Order ID", "Category", "Sub Category", "Item Id", "Item Name", "Listing Id", "Supplier Name", "Quantity",
             "Participant Full Name", "Participant Username","Recipient name", "Address", "Landmark", "City", "Pincode", "State", "Mobile", "Landline",
             "Client", "Scheme", "Status", "Dispatched To Participant Date", "Redeemed At Date",
             "Channel Price(Rs.)", "MRP(Rs.)", "Supplier Margin(%)", "Channel Price(Rs.)", "Base Price(Rs.)", "Base Margin(%)", "Client Price(Rs.)", "Client Margin(%)",
             "Aging Total", "Shipping Agent", "Shipping Code", "Reseller"]

  headers.each { |header|
    page.should have_content(header)
  }
end
