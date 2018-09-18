require 'request_spec_helper'

feature "Admin - Resellers Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  context "list" do

    scenario "should display list of resellers" do
      reseller = Fabricate(:reseller)
      client1 = Fabricate(:client, :client_name => "client1")
      client_reseller1 = Fabricate(:client_reseller, :reseller => reseller, :client => client1)

      client2 = Fabricate(:client, :client_name => "client2")
      client_reseller2 = Fabricate(:client_reseller, :reseller => reseller, :client => client2)

      @big_band_dhamaka = Fabricate(:scheme, :client => client1)
      Fabricate(:order_item, :scheme => @big_band_dhamaka, :price_in_rupees => 10_000)
      Fabricate(:order_item, :scheme => @big_band_dhamaka, :price_in_rupees => 20_000)
      Fabricate(:slab, :payout_percentage => 12, :lower_limit => 10_000, :client_reseller => client_reseller1)
      Fabricate(:slab, :payout_percentage => 12, :lower_limit => 10_000, :client_reseller => client_reseller2)

      visit(admin_user_management_resellers_path)

      within("#reseller_#{reseller.id}") {
        page.should have_content "Reseller"
        page.should have_content "client1, client2"
        page.should have_content("30,000")
        page.should have_content("3,600")
        page.should have_link("Edit", :href => edit_admin_user_management_reseller_path(reseller))
      }
    end

    scenario "should indicate that no resellers currently exist" do
      visit(admin_user_management_resellers_path)

      page.should have_content "There are no resellers yet"
    end
  end

  context "new" do
    scenario "should allow adding a new reseller" do
      visit(new_admin_user_management_reseller_path)

      fill_in('reseller_name', :with => 'Reseller Name')
      fill_in('reseller_email', :with => 'reseller@email.com')
      fill_in('reseller_phone_number', :with => '0948485853')

      click_on("Create Reseller")

      within(".alert") do
        page.should have_content "Reseller was successfully created."
      end

      page.should have_content "Edit"
      page.should have_link "Associate a client"
    end
  end

  context "edit" do

    scenario "should render reseller edit page after update" do
      client_reseller = Fabricate(:client_reseller)

      visit(edit_admin_user_management_reseller_path(client_reseller.reseller))

      fill_in('reseller_name', :with => 'Reseller Name')
      fill_in('reseller_email', :with => 'reseller@email.com')
      fill_in('reseller_phone_number', :with => '0948485853')

      click_on("Save Reseller")

      within(".alert") do
        page.should have_content "Reseller was successfully updated."
      end
    end

    scenario "should redirect to reseller index, on cancel" do
      client_reseller = Fabricate(:client_reseller)

      visit(edit_admin_user_management_reseller_path(client_reseller.reseller))

      click_on("Cancel")

      within(".resellers") do
        page.should have_content client_reseller.client.client_name
      end
    end

  end

  context "client resellers" do
    before :each do
      @reseller = Fabricate(:reseller)
      @client = Fabricate(:client, :client_name => "Test-Apple")
    end

    scenario "should associate a client to given reseller" do
      scheme = Fabricate(:scheme, :client => @client)
      order = Fabricate(:order, :user => Fabricate(:user, :client => @client))
      Fabricate(:order_item, :scheme => scheme, :order => order, :price_in_rupees => 1500, :created_at => Date.today.strftime("%d-%m-%Y"))

      visit(admin_user_management_resellers_path)
      within("#reseller_#{@reseller.id}") do
        click_on "Associate a client"
      end
      select @client.client_name, :from => "client_reseller_client_id"
      fill_in "client_reseller_finders_fee", :with => "1230"
      fill_in "client_reseller_payout_start_date", :with => Date.today.strftime("%d-%m-%Y")
      fill_in "client_reseller_slabs_attributes_0_lower_limit", :with => "1000"
      fill_in "client_reseller_slabs_attributes_1_lower_limit", :with => "2000"
      fill_in "client_reseller_slabs_attributes_2_lower_limit", :with => "3000"
      fill_in "client_reseller_slabs_attributes_0_payout_percentage", :with => "10"
      fill_in "client_reseller_slabs_attributes_1_payout_percentage", :with => "20"
      fill_in "client_reseller_slabs_attributes_2_payout_percentage", :with => "30"
      click_on "Associate client"

      within "#reseller_#{@reseller.id}" do
        page.should have_content @client.client_name
        click_on "Edit"
      end

      within(".client-resellers") do
        page.should have_content @client.client_name
        page.should have_content "1230"
        page.should have_content Date.today
        page.should have_content "1500"
        page.should have_content "150"
        page.should have_content "Assigned"
      end
    end

    scenario "should edit associated client info for given reseller" do
      client_reseller = Fabricate(:client_reseller, :client => @client, :reseller => @reseller, :finders_fee => 10_000, :payout_start_date => Date.today)
      Fabricate(:slab, :payout_percentage => 10, :lower_limit => 1_000, :client_reseller => client_reseller)
      Fabricate(:slab, :payout_percentage => 20, :lower_limit => 2_000, :client_reseller => client_reseller)
      Fabricate(:slab, :payout_percentage => 30, :lower_limit => 3_000, :client_reseller => client_reseller)
      Fabricate(:client, :client_name => "Test-Micro")


      visit(edit_admin_user_management_reseller_path(@reseller))
      within("#client_reseller_#{client_reseller.id}") do
        click_on "Edit"
      end

      within("h1") do
        page.should have_content("Edit a client - #{client_reseller.client.client_name}")
      end

      within(".client-info") do
        page.should_not have_content("Please Select")
        page.should_not have_content(client_reseller.client.client_name)
      end

      fill_in "client_reseller_finders_fee", :with => "4000"
      fill_in "client_reseller_payout_start_date", :with => Date.today.strftime("%d-%m-%Y")
      fill_in "client_reseller_slabs_attributes_0_lower_limit", :with => "5000"
      fill_in "client_reseller_slabs_attributes_1_lower_limit", :with => "6000"
      fill_in "client_reseller_slabs_attributes_2_lower_limit", :with => "7000"
      fill_in "client_reseller_slabs_attributes_0_payout_percentage", :with => "10"
      fill_in "client_reseller_slabs_attributes_1_payout_percentage", :with => "20"
      fill_in "client_reseller_slabs_attributes_2_payout_percentage", :with => "30"
      click_on "Update"

      within(".alert") do
        page.should have_content("Client reseller was successfully updated.")
      end

      within("#reseller_#{@reseller.id}") do
        page.should have_content client_reseller.client.client_name
      end
    end

    scenario "should unassign associated client for given reseller" do
      client_reseller = Fabricate(:client_reseller, :client => @client, :reseller => @reseller)

      visit(edit_admin_user_management_reseller_path(@reseller))
      within("#client_reseller_#{client_reseller.id}") do
        click_on "Unassign Client"
      end

      within(".alert") do
        page.should have_content("#{@client.client_name} successfully unassigned")
      end

      within("h1") do
        page.should have_content("Edit Reseller")
      end

      within(".client-resellers") do
        page.should have_content @client.client_name
        page.should have_content "Unassigned"
      end
    end

    scenario "should redirect to reseller index, on cancel" do
      client_reseller = Fabricate(:client_reseller, :client => @client, :reseller => @reseller, :finders_fee => 10_000, :payout_start_date => Date.today)

      visit(edit_admin_user_management_reseller_path(@reseller))
      within("#client_reseller_#{client_reseller.id}") do
        click_on "Edit"
      end
      click_on "Cancel"

      within(".resellers") do
        page.should have_content @client.client_name
      end
    end
  end
end