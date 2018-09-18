module Page
  module AdminLoginPage

    def navigate_to_admin_login_page
      visit path_to("admin sign in page")
    end

    def fill_and_submit_admin_login_form(username, password)
      fill_in('admin_user_username', :with => username)
      fill_in('admin_user_password', :with => password)
      click_button("Sign in")
    end


    def verify_admin_user_logged_in? username
      within("#header") do
        page.should have_content(username)
        page.should have_content("Logout")
      end
    end

  end
end

World(Page::AdminLoginPage)