module Page
  module OrderPage
    def fill_in_address_on_order_page(address)
      address.each { |key, val|
        fill_in(key.to_s, :with => val)
      }

    end

    def click_confirm_button_on_order_page
      click_button "Confirm"
    end
  end
end

World(Page::OrderPage)