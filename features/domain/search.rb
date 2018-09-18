module Domain
  module CukeSearch

    def search_for_keyword(keyword)
      enter_keyword_in_search_form(keyword)
      click_search_button
    end

    def verify_search_results_displayed(keyword)
      verify_results_in_search_results_page(keyword)
    end

    def verify_navigation_search_results(keyword)
      verify_left_navigation_search_results(keyword)
    end

    def index_items
      Sunspot.index! ClientItem.all
    end

  end
end

World(Domain::CukeSearch)