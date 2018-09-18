module Domain
  module CukeOrder
    def redeem_order_from_cart_page
      click_view_cart_link_on_catalogue_page
      click_redeem_button_on_cart_page
      fill_in_address_on_order_page(dummy_address)
      click_confirm_button_on_order_page
    end

    def redeem_single_redemption_item(title)
      single_redemption_redeem_item title
      fill_in_address_on_order_page(dummy_address)
      click_confirm_button_on_order_page
    end

    def confirm_order_on_confirmation_page
      click_confirm_button_on_order_page
    end

    def verify_order_preview(item_title)
      verify(shipping_address_on_page_displayed?(dummy_address), "Order address is not displayed on confirmation page")
      verify(order_items_are_shown_on_page(item_title), "Order items are not displayed on confirmation page")
    end

    def verify_order_created(item_title)
      verify(shipping_address_on_page_displayed?(dummy_address), "Order address is not displayed on thank you page")
      verify(order_id_is_shown_on_thank_you_page, "Order ID is not displayed on thank you page")
      #Commented because not sure what will be shown on order confirm/thank you page
      #verify(order_items_are_shown_on_page(item_title), "Order items are not displayed on thank you page")
    end

    def dummy_address
      {:order_address_name => 'bob',
       :order_address_body => 'Yerwada',
       :order_address_landmark => 'Netaji Chowk',
       :order_address_city => 'Pune',
       :order_address_state => 'Maharashtra',
       :order_address_zip_code => '606011',
       :order_address_phone => '6060155555'}
    end
  end
end

World(Domain::CukeOrder)