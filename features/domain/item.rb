module Domain
  module CukeItem

    def map_table_column_header_with_values(row)
      row.inject({}) do |result, (k, v)|
        result[k.underscore.gsub(/\s/, '_')] = row[k]
        result
      end
    end

    def verify_item_in_catalogue(item)
      verify(item_title_on_catalogue_page_displayed?(item[:title]), "Item title #{item[:title]} is not displayed on item catalogue page")
      verify(item_price_on_catalogue_page_displayed?(item[:price_shown]), "Item price #{item[:price_shown]} is not displayed on item catalogue page")
    end

    def verify_item_not_in_catalogue(item)
      verify(item_not_being_displayed(item[:title], item[:price_shown]), "Item with title #{item[:title]} is displayed on item catalogue page")
    end

    def verify_add_to_cart_from_item_description_page(item)
      verify_item_information_on_item_description_page(item)
      click_add_to_cart_button_on_item_description_page
    end

    def verify_item_information_on_item_description_page(item)
      navigate_to_item_description_page(item[:title])
      verify(item_title_on_item_description_page_displayed?(item[:title]), "Item title #{item[:title]} is not displayed on item description page")
      #verify(item_price_on_item_description_page_displayed?(item[:price_shown]), "Item price #{item[:price_shown]} is not displayed on item description page")
    end
  end
end

World(Domain::CukeItem)