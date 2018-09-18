module Page
  module CartPage
    def single_redemption_redeem_item item_title
      within(".catalogs") do
        click_link(item_title)
      end
      click_redeem_button_on_cart_page
    end

    def click_redeem_button_on_cart_page
      click_on "Redeem"
    end
  end
end

World(Page::CartPage)