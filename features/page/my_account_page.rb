module Page
  module MyAccountPage
    def navigate_to_my_account_page
      within("#myAccount") {
        page.execute_script("$('.theme-header-component').show()")
        click_link 'My Orders'
      }
    end

    def verify_order_displayed_to_participant(attributes)
      navigate_to_my_account_page
      attributes.each do |key, value|
        within ('.orders') do
          page.first('tr', :text => value).first(:xpath, "./..").has_content?(attributes["Product Description"]).should be_true
        end
      end
    end
  end
end

World(Page::MyAccountPage)