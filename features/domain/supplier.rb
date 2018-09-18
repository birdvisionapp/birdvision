module Domain
  module CukeSupplier
    def create_new_supplier supplier_info, row_index
      navigate_to_supplier_dashboard
      create_supplier(supplier_info)
    end
  end
end
World(Domain::CukeSupplier)