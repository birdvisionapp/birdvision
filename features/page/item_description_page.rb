module Page
  module ItemDescriptionPage

    def navigate_to_item_description_page(item_title)
      within(".catalogs") do
        click_link(item_title)
      end
    end

    def item_title_on_item_description_page_displayed?(title)
      page.has_content?(title)
    end

    def item_description_on_item_description_page_displayed?(description)
      page.has_content?(description)
    end

    def item_price_on_item_description_page_displayed?(price)
      page.has_content?(price)
    end

    def click_add_to_cart_button_on_item_description_page
      click_link("Add to cart")
    end
  end
end

World(Page::ItemDescriptionPage)