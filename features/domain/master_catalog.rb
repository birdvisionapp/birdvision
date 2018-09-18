module Domain
  module CukeMasterCatalog
    def add_bvc_price bvc_price, draft_item
      assign_bvc_price bvc_price, draft_item
    end

  end
end

World(Domain::CukeMasterCatalog)