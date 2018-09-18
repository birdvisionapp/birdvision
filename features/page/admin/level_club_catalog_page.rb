module Page
  module Admin
    module LevelClubCatalogPage
      def navigate_to_level_club_catalog(client, scheme, level, club)
        navigate_to_client_catalog_dashboard(client)
        within(".#{client.parameterize.underscore}") do
          click_link(scheme)
          click_link("#{level[0]}#{level[-1]}-#{club.titleize}")
        end
      end

      def assign_item_to_level_club_catalog client_item
        click_on "Add Items"
        table_row_id = find(:xpath, "//td[text()='#{client_item}']/..")[:id]
        within("##{table_row_id}") do
          find(".item_checkbox").set(true)
        end
        click_on "Add To Catalog"
      end
    end
  end
  module Participant
    module LevelClubCatalogPage
      def navigate_to_club_catalog club
        within(".#{club.downcase}-catalog") do
          click_on "View all"
        end
      end

      def cannot_redeem_item
        first(".not-eligible").should have_content("Not eligible")
      end

      def can_redeem_item
        first(".redeem").should have_content("Redeem")
      end
    end
  end
end

World(Page::Admin::LevelClubCatalogPage)
World(Page::Participant::LevelClubCatalogPage)