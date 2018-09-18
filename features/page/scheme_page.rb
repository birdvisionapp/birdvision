module Page
  module SchemePage

    def navigate_to_scheme_catalog scheme_name
      visit(schemes_path)
      within("#ready_for_redemption") do
        click_on scheme_name
      end
    end
  end
end

World(Page::SchemePage)