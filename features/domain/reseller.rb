module Domain
  module CukeReseller

    def verify_order_present_in_reseller_dashboard item, client_name, user
      navigate_to_reseller_order_dashboard client_name
      verify_order_on_reseller_order_dashboard_for_item item, user
    end
  end


end
World(Domain::CukeReseller)