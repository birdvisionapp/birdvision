require 'spec_helper'

describe Admin::Sales::ResellerDashboardController do
  login_reseller

  context "routes" do
    it "should route correctly" do
      {:get => admin_sales_reseller_dashboard_index_path}.should route_to('admin/sales/reseller_dashboard#index')
      {:get => admin_sales_client_participants_path(:client_id => '2')}.should route_to('admin/sales/reseller_dashboard#participants', :client_id => '2')
      {:get => admin_sales_client_orders_path(:client_id => '2')}.should route_to('admin/sales/reseller_dashboard#orders', :client_id => '2')
    end
  end

  context "Dashboard" do
    before :each do
      @reseller = Fabricate(:reseller, :admin_user => @admin)
      @client_reseller = Fabricate(:client_reseller, :reseller => @reseller)
      @client = @client_reseller.client
    end

    it "should list clients for the reseller" do
      client2 = Fabricate(:client)
      Fabricate(:client_reseller, :client => client2, :reseller => @reseller)
      client3 = Fabricate(:client)
      get :index

      assigns[:clients].should include(@client, client2)
      assigns[:clients].should_not include(client3)
      response.should be_success
    end

    it "should list orders placed after payout start date till today for a given client" do
      scheme = Fabricate(:scheme, :client => @client)
      order_item1 = Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 10_000, :created_at => @client_reseller.payout_start_date - 1.day)
      order_item2 = Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 2_000)
      order_item3 = Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 1_000)
      order_item4 = Fabricate(:order_item, :scheme => scheme, :price_in_rupees => 1_000, :created_at => Date.tomorrow)

      Fabricate(:slab, :payout_percentage => 12, :lower_limit => 1_000, :client_reseller => @client_reseller)
      get :orders, :client_id => @client.id

      assigns[:order_items].should include(order_item2, order_item3)
      assigns[:order_items].should_not include(order_item1, order_item4)
      assigns[:client].should == @client
      assigns[:total_sale_price].should == 3_000
      assigns[:payout].should == 360

      response.should be_success
    end

    it "should list participant details per scheme for a given client" do
      user1 = Fabricate(:user, :client => @client)
      user2 = Fabricate(:user, :client => @client)
      user3 = Fabricate(:user, :client => Fabricate(:client))

      scheme1 = Fabricate(:scheme, :client => @client)
      user_scheme1 = Fabricate(:user_scheme, :user => user1, :scheme => scheme1)
      user_scheme2 = Fabricate(:user_scheme, :user => user1, :scheme => scheme1)

      scheme2 = Fabricate(:scheme, :client => @client, :name => "ramdev baba scheme")
      user_scheme3 = Fabricate(:user_scheme, :user => user2, :scheme => scheme2)
      user_scheme4 = Fabricate(:user_scheme, :user => user2, :scheme => scheme2)

      scheme3 = Fabricate(:scheme, :client => user3.client, :name => "anna scheme")
      user_scheme5 = Fabricate(:user_scheme, :user => user3, :scheme => scheme3)

      get :participants, :client_id => @client.id

      assigns[:user_schemes].should include(user_scheme1, user_scheme2, user_scheme3, user_scheme4)
      assigns[:user_schemes].should_not include(user_scheme5)
      response.should be_success
    end
  end

  context "reports" do
    before :each do
      reseller = Fabricate(:reseller, :admin_user => @admin)
      @client_reseller = Fabricate(:client_reseller, :reseller => reseller)
      @client = @client_reseller.client
      @scheme = Fabricate(:scheme, :client => @client)
      @order_item1 = Fabricate(:order_item, :scheme => @scheme, :created_at => @client_reseller.payout_start_date - 1.day, :price_in_rupees => 10_000)
      @order_item2 = Fabricate(:order_item, :scheme => @scheme, :price_in_rupees => 2_000)
    end

    it "should return report of orders for the reseller" do
      get :orders, :client_id => @client.id, :format => :csv
      response.should be_success
      response.body.lines.count.should == 2
      response.body.should include "#{@order_item2.order.order_id}"
      response.body.should_not include "#{@order_item1.order.order_id}"
    end

    it "should return report of orders across pages" do
      @order_item3 = Fabricate(:order_item, :scheme => @scheme, :price_in_rupees => 10_000)
      with_pagination_override(OrderItem, 1) do
        get :orders, :client_id => @client.id, :format => :csv
      end
      response.should be_success
      response.body.lines.count.should == 3
      response.body.should_not include "#{@order_item1.order.order_id}"
      response.body.should include "#{@order_item2.order.order_id}"
      response.body.should include "#{@order_item3.order.order_id}"
    end

    it "should return report of participants for the reseller" do
      user1 = Fabricate(:user, :client => @client, :full_name => "batman")
      user2 = Fabricate(:user)

      Fabricate(:user_scheme, :user => user1, :scheme => @scheme)
      Fabricate(:user_scheme, :user => user2, :scheme => Fabricate(:scheme))

      get :participants, :client_id => @client.id, :format => :csv
      response.should be_success
      response.body.lines.count.should == 2
      response.body.should include "#{user1.full_name}"
      response.body.should_not include "#{user2.full_name}"
    end

    it "should return report of participants for the reseller across pages" do
      user1 = Fabricate(:user, :client => @client, :full_name => "batman")
      user2 = Fabricate(:user)
      user3 = Fabricate(:user, :client => @client, :full_name => "superman")

      Fabricate(:user_scheme, :user => user1, :scheme => @scheme)
      Fabricate(:user_scheme, :user => user2, :scheme => Fabricate(:scheme))
      Fabricate(:user_scheme, :user => user3, :scheme => @scheme)
      with_pagination_override(UserScheme, 1) do
        get :participants, :client_id => @client.id, :format => :csv
      end
      response.should be_success
      response.body.lines.count.should == 3
      response.body.should include "#{user1.full_name}"
      response.body.should_not include "#{user2.full_name}"
      response.body.should include "#{user3.full_name}"
    end
  end

end