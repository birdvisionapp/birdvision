module Domain
  module CukeLevelClubCatalog
    def add_to_level_club_catalog client, scheme, level, club, client_item
      navigate_to_level_club_catalog client, scheme, level, club
      assign_item_to_level_club_catalog client_item
    end

    def view_catalog club
      navigate_to_club_catalog club
    end

    def cannot_redeem
      cannot_redeem_item
    end

    def can_redeem
      can_redeem_item
    end
  end
end

World(Domain::CukeLevelClubCatalog)