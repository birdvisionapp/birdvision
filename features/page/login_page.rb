module Page
  module LoginPage

    def navigate_to_login_page
      visit path_to("sign in page")
    end

    def fill_and_submit_login_form(username, password)
      fill_in('user_username', :with => username)
      fill_in('user_password', :with => password)
      click_button("Sign in")
    end


    def verify_user_logged_in?
      all("#myAccount a").collect(&:text).should include("Logout")
    end

  end
end

World(Page::LoginPage)