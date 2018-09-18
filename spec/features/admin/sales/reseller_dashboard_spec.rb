require 'request_spec_helper'

feature "Reseller Dashboard" do

  before :each do
    admin_user = Fabricate(:admin_user, :role => AdminUser::Roles::RESELLER)
    reseller = Fabricate(:reseller, :admin_user => admin_user)

    @emerson = Fabricate(:client, :client_name => "Emerson")
    @axis = Fabricate(:client, :client_name => "Axis")

    Fabricate(:client_reseller, :client => @emerson, :reseller => reseller)
    Fabricate(:client_reseller, :client => @axis, :reseller => reseller)

    @big_band_dhamaka = Fabricate(:scheme, :client => @emerson)
    @order_item1 = Fabricate(:order_item, :scheme => @big_band_dhamaka, :price_in_rupees => 10_000)
    @order_item2 = Fabricate(:order_item, :scheme => @big_band_dhamaka, :price_in_rupees => 20_000)
    login_as admin_user, :scope => :admin_user
  end

  context "dashboard" do
    scenario "should render dashboard for reseller" do
      visit admin_sales_reseller_dashboard_index_path
      page.should have_link("Clients", admin_sales_reseller_dashboard_index_path)
      page.should have_content("Clients")
      within("#client_#{@emerson.id}") do
        page.should have_content(@emerson.client_name)
        page.should have_content("30,000")
      end
    end
  end

  context "Orders" do
    scenario "should list orders for a client of the reseller" do
      visit admin_sales_reseller_dashboard_index_path
      within("#client_#{@emerson.id}") do
        click_on "Orders Report"
      end
      page.should have_content("#{@emerson.client_name} - Orders")
      order = @order_item1.order
      item = @order_item1.client_item.item
      within("#order_item_#{@order_item1.id}") do
        page.should have_content(order.order_id)
        page.should have_content(item.title)
        page.should have_content(@order_item1.quantity)
        page.should have_content(order.user.full_name)
        page.should have_content(@order_item1.scheme.name)
        page.should have_content(@order_item1.status.humanize)
        page.should have_content(@order_item1.price_in_rupees)
        page.should have_content(@order_item1.points_claimed)
      end
    end

    scenario "should download orders report a client of the reseller" do
      visit admin_sales_reseller_dashboard_index_path
      within("#client_#{@emerson.id}") do
        click_on "Orders Report"
      end
      click_on "Orders report"
      order = @order_item1.order
      item = @order_item1.client_item.item
      page.should have_content(order.order_id)
      page.should have_content(item.title)
      page.should have_content(@order_item1.quantity)
      page.should have_content(order.user.full_name)
      page.should have_content(@order_item1.scheme.name)
      page.should have_content(@order_item1.status.humanize)
      page.should have_content(@order_item1.price_in_rupees)
      page.should have_content(@order_item1.points_claimed)
    end
  end

  context "Participants" do
    context "Point Based" do
      before :each do
        @user_scheme = Fabricate(:user_scheme, :scheme => @big_band_dhamaka)
      end
      scenario "should list participants a reseller" do
        visit admin_sales_reseller_dashboard_index_path
        within("#client_#{@emerson.id}") do
          click_on "Participants Report"
        end
        page.should have_content("#{@emerson.client_name} - Participants")
        user1 = @user_scheme.user
        within("#user_scheme_#{@user_scheme.id}") do
          page.should have_content(@big_band_dhamaka.name)
          page.should have_content(user1.participant_id)
          page.should have_content(user1.username)
          page.should have_content(user1.full_name)
          page.should have_content(@user_scheme.total_points)
        end
      end

      scenario "should download participants report a client of the reseller" do
        visit admin_sales_reseller_dashboard_index_path
        within("#client_#{@emerson.id}") do
          click_on "Participants Report"
        end
        click_on "Participants report"
        user1 = @user_scheme.user
        page.should have_content(@big_band_dhamaka.name)
        page.should have_content(user1.participant_id)
        page.should have_content(user1.username)
        page.should have_content(user1.full_name)
        page.should have_content(@user_scheme.total_points)
      end
    end
  end

  context "single redemption client" do
    before :each do
      @scheme = Fabricate(:scheme, :single_redemption => true, :client => @axis)
      @user_scheme = Fabricate(:user_scheme, :scheme => @scheme, :current_achievements => 20_000)
      @single_redemption_order_item = Fabricate(:order_item, :order => Fabricate(:order, :user => @user_scheme.user), :scheme => @scheme, :price_in_rupees => 10_000)
    end

    scenario "should list participants of a reseller" do
      client = @user_scheme.scheme.client
      user = @user_scheme.user
      visit admin_sales_reseller_dashboard_index_path
      within("#client_#{client.id}") do
        click_on "Participants Report"
      end
      page.should have_content("#{client.client_name} - Participants")
      within("#user_scheme_#{@user_scheme.id}") do
        page.should have_content(@scheme.name)
        page.should have_content(user.participant_id)
        page.should have_content(user.username)
        page.should have_content(user.full_name)
        page.should have_content("20,000")
        page.should have_content("10,000")
      end
    end

    scenario "should download participants report for the client of the reseller" do
      visit admin_sales_reseller_dashboard_index_path
      within("#client_#{@axis.id}") do
        click_on "Participants Report"
      end
      click_on "Participants report"
      user = @user_scheme.user
      page.should have_content(@scheme.name)
      page.should have_content(user.participant_id)
      page.should have_content(user.username)
      page.should have_content(user.full_name)
      page.should have_content("20000")
      page.should have_content("10000")
    end
  end
end