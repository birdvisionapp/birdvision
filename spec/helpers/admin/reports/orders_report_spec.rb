require 'spec_helper'

describe Admin::Reports::OrdersReport do

  context "orders report" do
    include Admin::Reports::OrdersReport
    before :each do
      flipkart = Fabricate(:supplier, :name => "flipkart")
      infibeam = Fabricate(:supplier, :name => "infibeam")
      s2 = Fabricate(:item, :title => "samsung s2 black")
      Fabricate(:item_supplier, :item => s2, :mrp => 30_000, :channel_price => 18_000, :supplier => flipkart)
      s3 = Fabricate(:item, :title => "S3")
      Fabricate(:item_supplier, :item => s3, :mrp => 30_000, :channel_price => 18_000, :supplier => infibeam)

      client_catalog = Fabricate(:client_catalog)
      Fabricate(:client_reseller, :client => client_catalog.client)

      @order_item1 = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => s2, :client_catalog => client_catalog), :created_at => Time.now - 2.days, :quantity => 1,
                               :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :mrp => 5_000, :supplier_id => flipkart.id, :shipping_code => "123", :shipping_agent => "DHL", :status => :sent_to_supplier)
      @order_item1.send_for_delivery
      @order_item2 = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => s3, :client_catalog => client_catalog), :created_at => Time.now - 2.days, :quantity => 1,
                               :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :mrp => 5_000, :supplier_id => infibeam.id, :shipping_code => "34567", :shipping_agent => "DHL", :status => :sent_to_supplier)

    end

    def all
      [@order_item1, @order_item2]
    end

    it "should generate csv" do
      csv = to_csv

      csv.should include(['Order ID', 'Category', 'Sub Category', 'Item Id', 'Item Name', 'Listing Id', 'Supplier Name', 'Quantity', 'Participant Full Name',
                          'Participant Username', 'Recipient name', 'Address', 'Landmark', 'City', 'Pincode', 'State', 'Mobile', 'Landline', 'Client', 'Scheme',
                          'Status', 'Dispatched To Participant Date', 'Redeemed At Date', 'Points', 'MRP(Rs.)', 'Supplier Margin(%)', 'Channel Price(Rs.)', 'Base Price(Rs.)',
                          'Base Margin(%)', 'Client Price(Rs.)', 'Client Margin(%)', 'Aging Total', 'Shipping Agent', 'Shipping Code', 'Reseller'].join(","))
      order = @order_item1.order
      item = @order_item1.client_item.item


      csv.should include([order.order_id, @order_item1.parent_category, item.category.title, item.id, item.title, item.preferred_supplier.listing_id,
                          @order_item1.supplier.name, @order_item1.quantity, order.user.full_name, order.user.username, order.address_name, order.address_body, order.address_landmark, order.address_city,
                          order.address_zip_code, order.address_state, order.address_phone, order.address_landline_phone, order.user.client_name, @order_item1.scheme.name, @order_item1.status_for_report,
                          @order_item1.dispatched_to_participant_date == "" ? "" : @order_item1.dispatched_to_participant_date.strftime("%d-%b-%Y"), @order_item1.created_at.strftime("%d-%b-%Y"), @order_item1.points_claimed,
                          @order_item1.mrp, @order_item1.supplier_margin, @order_item1.channel_price, @order_item1.bvc_price, @order_item1.bvc_margin, @order_item1.price_in_rupees/@order_item1.quantity, @order_item1.client_margin,
                          @order_item1.distance_of_time_in_words, @order_item1.shipping_agent, @order_item1.shipping_code, @order_item1.reseller_name].join(","))
    end

    it "should generate csv for client manager" do
      csv = to_csv("client_manager")

      csv.should include(['Order ID', 'Category', 'Sub Category', 'Item Id', 'Item Name', 'Quantity', 'Participant Full Name',
                          'Participant Username', 'Recipient name', 'Address', 'Landmark', 'City', 'Pincode', 'State', 'Mobile', 'Landline', 'Client', 'Scheme',
                          'Status', 'Dispatched To Participant Date', 'Redeemed At Date', 'Points', 'MRP(Rs.)',
                          'Client Price(Rs.)', 'Aging Total', 'Shipping Agent', 'Shipping Code'].join(","))
      order = @order_item1.order
      item = @order_item1.client_item.item

      csv.should include([order.order_id, @order_item1.parent_category, item.category.title, item.id, item.title, @order_item1.quantity, order.user.full_name, order.user.username, order.address_name, order.address_body, order.address_landmark, order.address_city,
                          order.address_zip_code, order.address_state, order.address_phone, order.address_landline_phone, order.user.client_name, @order_item1.scheme.name, @order_item1.status_for_report,
                          @order_item1.dispatched_to_participant_date == "" ? "" : @order_item1.dispatched_to_participant_date.strftime("%d-%b-%Y"), @order_item1.created_at.strftime("%d-%b-%Y"), @order_item1.points_claimed,
                          @order_item1.mrp,  @order_item1.price_in_rupees/@order_item1.quantity,
                          @order_item1.distance_of_time_in_words, @order_item1.shipping_agent, @order_item1.shipping_code].join(","))
    end
  end
end