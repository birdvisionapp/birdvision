require 'request_spec_helper'

feature "Login/Logout" do
  context "login" do
    let(:user_scheme) { Fabricate(:user_scheme, :scheme => Fabricate(:scheme)) }
    let(:user) { user_scheme.user }
    let(:admin_user) { Fabricate(:admin_user) }
    let(:client_manager_admin_user) { Fabricate(:client_manager_admin_user) }
    let(:reseller_admin_user) { Fabricate(:reseller_admin_user) }

    scenario "should redirect signed in user to items page" do
      visit(root_path)
      fill_in('user_username', :with => user.username)
      fill_in('user_password', :with => user.password)
      click_button("Sign in")
      within('#myAccount .user-name') do
        page.should have_content user.full_name
      end
      current_url.should include(schemes_path)
      click_link("Logout")
      current_url.should include(new_user_session_path)
    end
    
    scenario "should redirect signed in user to requested url" do
      visit(order_index_path)
      fill_in('user_username', :with => user.username)
      fill_in('user_password', :with => user.password)
      click_button("Sign in")
      within('.user-name') do
        page.should have_content user.full_name
      end
      current_url.should include(order_index_path)
      click_link("Logout")
      current_url.should include(new_user_session_path)
    end

    scenario "should redirect signed in admin user to admin page" do
      visit(new_admin_category_path)
      fill_in('admin_user_username', :with => admin_user.username)
      fill_in('admin_user_password', :with => admin_user.password)
      click_button("Sign in")
      within('.user-actions') do
        page.should have_content admin_user.username
      end
      current_url.should include(admin_root_path)

      click_link("Logout")
      current_url.should include(new_admin_user_session_path)
    end

    scenario "should take to admin dashboard for admin login" do
      visit(admin_path)
      fill_in('admin_user_username', :with => admin_user.username)
      fill_in('admin_user_password', :with => admin_user.password)
      click_button("Sign in")
      within('.user-actions') do
        page.should have_content admin_user.username
      end
      current_url.should include(admin_dashboard_path)
    end
    scenario "should take to admin dashboard for client manager login" do
      Fabricate(:client_manager, :admin_user => client_manager_admin_user)
      visit(admin_path)
      fill_in('admin_user_username', :with => client_manager_admin_user.username)
      fill_in('admin_user_password', :with => client_manager_admin_user.password)
      click_button("Sign in")
      within('.user-actions') do
        page.should have_content client_manager_admin_user.username
      end
      current_url.should include(admin_dashboard_path)
    end
    scenario "should take to admin dashboard for reseller login" do
      Fabricate(:reseller, :admin_user => reseller_admin_user)
      visit(admin_path)
      fill_in('admin_user_username', :with => reseller_admin_user.username)
      fill_in('admin_user_password', :with => reseller_admin_user.password)
      click_button("Sign in")
      within('.user-actions') do
        page.should have_content reseller_admin_user.username
      end
      current_url.should include(admin_sales_reseller_dashboard_index_path)
    end
  end
end