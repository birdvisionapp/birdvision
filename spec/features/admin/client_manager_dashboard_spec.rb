require 'request_spec_helper'
feature 'Client Manager Dashboard' do
  before :each do
    @acme = Fabricate(:client, :client_name => "Acme Inc")
    client_manager_admin_user = Fabricate(:client_manager_admin_user)
    @client_manager = Fabricate(:client_manager, :client => @acme, :admin_user => client_manager_admin_user)
    login_as client_manager_admin_user, :scope => :admin_user
  end

  scenario "should be able to see scheme details" do
    Fabricate(:future_scheme, :name => "upcoming_scheme", :client => @acme)
    Fabricate(:expired_scheme, :name => "Expired Scheme", :client => @acme)
    gold_rush = Fabricate(:scheme, :name => "Gold Rush", :client => @acme)
    gold_sprint = Fabricate(:scheme, :name => "Gold Sprint", :client => @acme)

    Fabricate(:user_scheme, :scheme => gold_rush, :total_points => 1_234)
    Fabricate(:user_scheme, :scheme => gold_sprint, :total_points => 20_567)

    visit(admin_dashboard_path)
    within('.schemes') do
      within('.number-data') do
        page.should have_content "2"
        page.should have_content "Ready For Redemption"
      end
      page.should have_content "Upcoming - 1"
      page.should have_content "Past - 1"
      page.should have_link('', :href => admin_schemes_path)
    end
    within('.scheme-budget') do
      within('.number-data') do
        page.should have_content '2,180.1 Total Rs.'
      end
      within('.description') do
        page.should have_content "Gold Rush"
        page.should have_content "1,234"
        page.should have_content "123.4"
        page.should have_content "Gold Sprint"
        page.should have_content "20,567"
        page.should have_content "2,056.7"
      end
      page.should have_link('', :href => admin_schemes_path)
    end
  end

  scenario "should be able to see participant details" do
    Fabricate(:user, :client => @acme, :activation_status => User::ActivationStatus::ACTIVATED)
    Fabricate(:user, :client => @acme, :activation_status => User::ActivationStatus::LINK_NOT_SENT)
    Fabricate(:user, :client => @acme, :activation_status => User::ActivationStatus::NOT_ACTIVATED)
    visit(admin_dashboard_path)
    within('.participants') do
      within('.number-data') do
        page.should have_content "1"
      end
      within('.sub-title') do
        page.should have_content "Activated"
      end
      within('.description') do
        page.should have_content "Not Activated"
        page.should have_content "2"
      end
      page.should have_link('', :href => admin_users_path )
    end
  end

  scenario "should be able to see order details" do
    gold_rush = Fabricate(:scheme, :name => "Gold Sprint", :client => @acme, :total_budget_in_rupees => 1_000)
    rajesh = Fabricate(:user, :client => @acme)
    acme_client_item = Fabricate(:client_item, :client_catalog => @acme.client_catalog)
    Fabricate(:order_item, :order => Fabricate(:order, :user => rajesh), :scheme => gold_rush,
              :client_item => acme_client_item, :status => :delivery_in_progress)
    Fabricate(:order_item, :order => Fabricate(:order, :user => rajesh), :scheme => gold_rush,
              :client_item => acme_client_item, :status => :new)
    Fabricate(:order_item, :order => Fabricate(:order, :user => rajesh), :scheme => gold_rush,
              :client_item => acme_client_item, :status => :delivered)
    Fabricate(:order_item, :order => Fabricate(:order, :user => rajesh), :scheme => gold_rush,
              :client_item => acme_client_item, :status => :sent_to_supplier)
    Fabricate(:order_item, :order => Fabricate(:order, :user => rajesh), :scheme => gold_rush,
              :client_item => acme_client_item, :status => :incorrect)
    visit(admin_dashboard_path)
    within('.orders') do
      within('.number-data') do
        page.should have_content "5"
      end
      within('.sub-title') do
        page.should have_content "Order(s) placed"
      end
      within('.description') do
        page.should have_content "New - 1"
        page.should have_content "Sent to supplier - 1"
        page.should have_content "Delivery in progress - 1"
        page.should have_content "Delivered - 1 "
        page.should have_content "Incorrect - 1 "
      end
      page.should have_link('', :href => admin_order_items_path)
    end
  end

  scenario "should show total redemption value for a scheme" do
    gold_rush = Fabricate(:scheme, :name => "Gold Rush", :client => @acme)
    gold_sprint = Fabricate(:scheme, :name => "Gold Sprint", :client => @acme)
    Fabricate(:order_item, :price_in_rupees => 1_234, :points_claimed =>12_340, :scheme => gold_rush )
    Fabricate(:order_item, :price_in_rupees => 20_567, :points_claimed =>2_05_670, :scheme => gold_sprint )

    visit(admin_dashboard_path)
    within('.scheme-redemption') do
      page.should have_content '21,801'
      within("#scheme_#{gold_rush.id}") do
        page.should have_content "1,234"
        page.should have_content "12,340"
      end
      within("#scheme_#{gold_sprint.id}") do
        page.should have_content "20,567"
        page.should have_content "2,05,670"
      end
    end
  end

  scenario "should have links to download report for orders, participants" do
    visit(admin_dashboard_path)
    within('.btn-group') do
      page.should have_link 'Orders Report', admin_order_items_path(:format => "csv")
      page.should have_link 'Participants Report', admin_users_path(:format => "csv")
      page.should have_link 'Points Statement Report', admin_scheme_transactions_path(:format => "csv")
    end
  end

  scenario "should allow searching participants with email,username or full name" do
    anthony = Fabricate(:user, :client => @acme, :full_name => "Anthony Gonsalvis")
    visit(admin_dashboard_path)
    fill_in 'q_username_or_full_name_cont', :with => anthony.username
    find("#searchForm .btn").click
    within('.users') do
      page.should have_content anthony.username
      page.should have_content "Anthony Gonsalvis"
    end
  end

end

