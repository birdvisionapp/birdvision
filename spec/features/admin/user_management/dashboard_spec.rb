require 'request_spec_helper'

feature "User Management Dashboard" do

  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  scenario "should display list of user counts per role" do
    Fabricate(:super_admin_user)
    Fabricate(:client_manager)
    Fabricate(:client_manager)
    Fabricate(:reseller)

    visit(admin_user_management_dashboard_path)

    within("#super_admins") do
      page.should have_content("Super Admins")
      page.should have_content("2") # 2, as one we used to login with and the other we just fabricated :)
      page.should have_link("Manage", admin_user_management_super_admins_path)
    end

    within("#resellers") do
      page.should have_content("Resellers")
      page.should have_content("1")
      page.should have_link("Manage", admin_user_management_resellers_path)
    end

    within("#client_managers") do
      page.should have_content("Client Managers")
      page.should have_content("2")
      page.should have_link("Manage", admin_user_management_client_managers_path)
    end
  end

  scenario "should display list of user counts per role even when count is zero" do
    visit(admin_user_management_dashboard_path)

    within("#super_admins") do
      page.should have_content("Super Admins")
      page.should have_content("1")  # as one we used to login with
      page.should have_link("Manage", admin_user_management_super_admins_path)
    end

    within("#resellers") do
      page.should have_content("Resellers")
      page.should have_content("0")
      page.should have_link("Manage", admin_user_management_resellers_path)
    end

    within("#client_managers") do
      page.should have_content("Client Managers")
      page.should have_content("0")
      page.should have_link("Manage", admin_user_management_client_managers_path)
    end
  end

end
