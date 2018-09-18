module Page
  module ThankYouPage
    def shipping_address_on_page_displayed?(address)
      within(".vcard") do
        address.values.all? { |addr|
          page.has_content?(addr)
        }
      end
    end

    def order_id_is_shown_on_thank_you_page
      find("#orderInfo").text.should =~ /Order: \d*/
    end

    def order_items_are_shown_on_page(item_title)
      within("#orderItems") do
        page.has_content?(item_title)
      end
    end
  end
end

World(Page::ThankYouPage)