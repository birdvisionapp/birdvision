require 'spec_helper'

describe Admin::OrderItemsController do
  login_admin

  context "routes" do
    it "should route correctly" do
      {:put => admin_order_item_change_status_path(:order_item_id => 1)}.should route_to('admin/order_items#change_status', :order_item_id => '1')
      {:get => admin_order_item_edit_tracking_info_path(:order_item_id => 1)}.should route_to('admin/order_items#edit_tracking_info', :order_item_id => '1')
      {:put => admin_order_item_update_tracking_info_path(:order_item_id => 1)}.should route_to('admin/order_items#update_tracking_info', :order_item_id => '1')
    end
  end
  let(:scheme) { Fabricate(:scheme) }
  context "browse all orders" do

    it "should show all order items " do
      order_item_old = Fabricate(:order_item, :created_at => Time.now - 2.days, :scheme => scheme)
      order_item_new = Fabricate(:order_item, :scheme => scheme)

      get :index
      assigns[:orders].should == [order_item_new, order_item_old]
      response.should be_success
    end

    it "should download only the filtered order items" do
      flipkart = Fabricate(:supplier, :name => "flipkart")
      infibeam = Fabricate(:supplier, :name => "infibeam")
      s2 = Fabricate(:item, :title => "samsung s2 black")
      Fabricate(:item_supplier, :item => s2, :mrp => 30_000, :channel_price => 18_000, :supplier => flipkart)
      s3 = Fabricate(:item, :title => "S3")
      Fabricate(:item_supplier, :item => s3, :mrp => 30_000, :channel_price => 18_000, :supplier => infibeam)
      mac = Fabricate(:item, :title => "macbook pro")
      Fabricate(:item_supplier, :item => mac, :mrp => 1_30_000, :channel_price => 1_80_000, :supplier => flipkart)

      order_item_1 = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => s2), :created_at => Time.now - 2.days, :quantity => 1, :scheme => scheme,
                               :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :mrp => 5_000, :supplier_id => flipkart.id)
      order_item_2 = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => s3), :created_at => Time.now - 2.days, :quantity => 1, :scheme => scheme,
                               :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000, :mrp => 5_000, :supplier_id => infibeam.id)
      order_item_3 = Fabricate(:order_item, :client_item => Fabricate(:client_item, :item => mac), :quantity => 1, :created_at => Time.now - 2.days, :quantity => 1, :scheme => scheme,
                               :channel_price => 1_80_000, :bvc_price => 1_60_000, :price_in_rupees => 1_70_000, :mrp => 1_90_000, :supplier_id => flipkart.id)
      with_pagination_override(OrderItem, 1) do
        get :index, :q => {:supplier_id_eq => flipkart.id}, :format => :csv
      end
      response.should be_success
      response.body.lines.count.should == 3
      response.body.should include "samsung s2 black"
      response.body.should include "macbook pro"
      response.body.should_not include "S3"
    end

    context "change order item status" do
      before(:each) do
        @order_item = Fabricate(:order_item, :order => Fabricate(:order), :scheme => scheme)
      end
      it "should update status" do
        put :change_status, {:order_item_id => @order_item.id, :perform_action => :send_to_supplier}

        @order_item.reload.status.should == 'sent_to_supplier'
        response.should redirect_to(admin_order_items_path)
      end

      context "validation" do
        it "should not allow to do invalid order item status change" do

          put :change_status, {:order_item_id => @order_item.id, :perform_action => :delete}

          @order_item.reload.status.should == 'new'
          flash[:notice].should == "You are performing an invalid action"
          response.should redirect_to(admin_order_items_path)
        end
      end

      it "should save name of admin who updated status" do
        with_versioning do
          @order_item.send_to_supplier
          @order_item.versions.last.whodunnit.should == @admin.username
        end
      end
    end
  end

  context "filters by created at" do

    it "should filter between start of day and end of day when created_at_date_gteq,created_at_date_lteq even when fields are same" do
      order_attributes = {:quantity => 1,
                          :channel_price => 8_000, :bvc_price => 10_000, :price_in_rupees => 12_000,
                          :shipping_code => "123", :shipping_agent => "DHL", :mrp => 5_000, :scheme => scheme,
                          :status => :new}
      item_today = Fabricate(:order_item, order_attributes.merge(:created_at => Date.today))
      item_tomorrow = Fabricate(:order_item, order_attributes.merge(:created_at => Date.tomorrow))
      item_now = Fabricate(:order_item, order_attributes.merge(:created_at => Time.now))
      item_yesterday = Fabricate(:order_item, order_attributes.merge(:created_at => Date.yesterday))

      get :index, :q => {:created_at_date_gteq => Date.today.strftime("%d-%m-%Y"), :created_at_date_lteq => Date.today.strftime("%d-%m-%Y")}
      items = assigns[:orders]
      items.length.should == 2
      items.should include(item_today, item_now)

    end

  end

  context "shipping info" do
    it "should show edit tracking info form" do
      order_item = Fabricate(:order_item, :order => Fabricate(:order), :scheme => scheme)
      get :edit_tracking_info, {:order_item_id => order_item.id}

      assigns[:order_item].should == order_item
      response.should be_success
    end

    it "should update tracking info form" do
      order_item = Fabricate(:order_item, :order => Fabricate(:order), :scheme => scheme)
      order_item_title=order_item.client_item.title
      order_item_id=order_item.order.order_id
      put :update_tracking_info, {
          :order_item_id => order_item.id,
          :order_item => {
              :shipping_agent => 'XXX',
              :shipping_code => 'YYY'

          }
      }
      flash[:notice].should == "The tracking info for %s in Order ID. %s was updated successfully" % [order_item_title, order_item_id]
      response.should redirect_to admin_order_items_path
    end

  end
end