module Page
  module CataloguePage
    def item_title_on_catalogue_page_displayed?(title)
      all('.items-grid .item-title').collect(&:text).should include(title)
    end

    def item_not_being_displayed(title, price)
      page.has_content?(title).should be_false
    end

    def category_displayed_on_catalog_page category_title
      all(".category-list li").collect(&:text).should include(category_title)
    end

    def item_price_on_catalogue_page_displayed?(price)
      all(".item-points").collect { |x| x.text.gsub(',', '') }.should include(price)
    end

    def item_image_url_is_displayed?(image_url, item_id)
      within("#item_id_#{item_id}") do
        page.find(".image-container img")["src"].should include(image_url)
      end
    end

    def item_added_to_cart_message_displayed_on_catalogue_page?(title)
      page.has_content?("#{title} is added to your cart")
    end

    def click_view_cart_link_on_catalogue_page
      click_link "View cart"
    end

    def enter_keyword_in_search_form(keyword)
      fill_in("search_keyword", :with => keyword)
    end

    def click_search_button
      find("#searchForm .btn").click
    end

    def click_logout
      page.execute_script("$('.theme-header-component').show()")
      find(".logout").click
    end
  end
end

World(Page::CataloguePage)