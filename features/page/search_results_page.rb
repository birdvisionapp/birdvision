module Page
  module SearchResultsPage

    def verify_results_in_search_results_page keyword
      within("#searchResults") do
        page.should have_link(keyword)
      end
    end

    def verify_left_navigation_search_results(keyword)
      within(".search-result-category-list") do
        page.should have_content("#{keyword} (1)")
      end
    end
  end
end

World(Page::SearchResultsPage)