module Page
  module OrderPreviewPage
    def click_confirm_button_on_order_preview_page
      click_button "Confirm"
    end
  end
end

World(Page::OrderPreviewPage)