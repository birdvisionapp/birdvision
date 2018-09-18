module Domain
  module CukeClientCatalog
    def add_items_to_client_catalog client, client_item
      navigate_to_client_catalog_dashboard client
      add_to_client_catalog client_item
    end

    def remove_items_from_client_catalog client, client_item
      navigate_to_client_catalog_dashboard client
      remove_from_client_catalog client_item
    end

    def assign_client_price_to_the_item client, client_item, client_price
      navigate_to_client_catalog_dashboard client
      assign_client_price client_item, client_price
    end

    def add_item_to_scheme_catalog(scheme, client, client_item)
      navigate_to_scheme_catalog_dashboard(scheme, client)
      add_to_scheme_catalog client_item
    end

  end
end

World(Domain::CukeClientCatalog)