module Admin::Reports::CatalogReports
  include Admin::ItemHelper
  include ViewsHelper

  module MasterCatalog
    include Admin::Reports::CatalogReports

    def csv_headers
      ["Item Id", "Item Name", "Category", "Sub Category", "All Suppliers", "Pref. Supplier", "Pref. Supplier - Listing Id",
        "Pref. Supplier - Delivery Time", "Pref. Supplier - Geographic Reach", "Pref. Supplier - Available Quantity",
        "Pref. Supplier - Available till Date", "Channel Price(Rs.)", "MRP(Rs.)", "Base Price(Rs.)", "Base Margin(%)",
        "Supplier Margin(%)", "Clients"]
    end

    def to_csv options = {}
      CSV.generate do |csv|
        csv_headers.unshift("MSP") if options[:is_super_admin]
        csv << csv_headers
        find_each(:batch_size => 6000) do |item|
          preferred_supplier = item.preferred_supplier
          row = [
            item.id,
            item.title,
            item.category.parent.nil? ? '' : item.category.parent.title,
            item.category.nil? ? '' : item.category.title,
            item.supplier_names,
            preferred_supplier.supplier.name,
            preferred_supplier.listing_id,
            preferred_supplier.delivery_time,
            preferred_supplier.geographic_reach,
            preferred_supplier.available_quantity,
            preferred_supplier.available_till_date,
            preferred_supplier.channel_price,
            preferred_supplier.mrp,
            item.bvc_price,
            item.margin,
            preferred_supplier.supplier_margin,
            get_client_names_csv_for(item)
          ]
          row.unshift(item.category.msp_name) if options[:is_super_admin]
          csv << row
        end
      end
    end    
  end

  module ClientCatalog
    include Admin::Reports::CatalogReports

    def to_csv options = {}
      CSV.generate do |csv|
        csv << send("csv_headers_for_#{options[:role]}", options)
        find_each do |client_item|
          csv << send("csv_row_for_#{options[:role]}", client_item, options)
        end
      end
    end

    def csv_headers_for_super_admin(options)
      header = ["Item Id", "Item Name", "Category", "Sub Category", "Pref. Supplier", "MRP(Rs.)", "Channel Price(Rs.)",
        "Supplier margin(%)", "Base Price(Rs.)", "Base Margin(%)", "Client Price(Rs.)", "Client Margin(%)", "Points", "Schemes"]
      header.unshift("MSP") if options[:is_super_admin]
      header
    end

    def csv_row_for_super_admin(client_item, options)
      item = client_item.item
      row = [
        item.id,
        item.title,
        item.category.parent.nil? ? '' : item.category.parent.title,
        item.category.nil? ? '' : item.category.title,
        item.preferred_supplier.supplier.name,
        item.preferred_supplier.mrp,
        item.channel_price,
        item.preferred_supplier.supplier_margin,
        item.bvc_price,
        item.margin.nil? ? '' : item.margin,
        client_item.client_price,
        client_item.margin.nil? ? '' : client_item.margin,
        client_item.client_price.nil? ? '' : client_item.price_to_points,
        schemes_for(client_item)
      ]
      row.unshift(item.category.msp_name) if options[:is_super_admin]
      row
    end

    def csv_headers_for_client_manager(options)
      ["Item Id", "Item Name", "Category", "Sub Category", "MRP(Rs.)", "Client Price(Rs.)", "Points", "Schemes"]
    end

    def csv_row_for_client_manager(client_item, options)
      item = client_item.item
      [
        item.id,
        item.title,
        item.category.parent.nil? ? '' : item.category.parent.title,
        item.category.nil? ? '' : item.category.title,
        item.preferred_supplier.mrp,
        client_item.client_price,
        client_item.client_price.nil? ? '' : client_item.price_to_points,
        schemes_for(client_item)
      ]
    end
  end

  module SchemeCatalog
    def csv_headers_for_super_admin(options)
      header = ["Item Id", "Item Name", "Category", "Sub Category", "Pref. Supplier", "MRP(Rs.)", "Channel Price(Rs.)", "Supplier margin(%)",
        "Base Price(Rs.)", "Base Margin(%)", "Client Price(Rs.)", "Client Margin(%)", "Points"]
      header.unshift("MSP") if options[:is_super_admin]
      header
    end
    def csv_headers_for_client_manager(options)
      ["Item Id", "Item Name", "Category", "Sub Category", "MRP(Rs.)", "Client Price(Rs.)", "Points"]
    end

    def to_csv options = {}
      CSV.generate do |csv|
        csv << send("csv_headers_for_#{options[:role]}", options)
        find_each do |catalog_item|
          csv << send("csv_row_for_#{options[:role]}",catalog_item, options)
        end
      end
    end

    def csv_row_for_super_admin(catalog_item, options)
      client_item= catalog_item.client_item
      item = client_item.item
      row = [
        item.id,
        item.title,
        item.category.parent.nil? ? '' : item.category.parent.title,
        item.category.nil? ? '' : item.category.title,
        item.preferred_supplier.supplier.name,
        item.preferred_supplier.mrp,
        item.channel_price,
        item.preferred_supplier.supplier_margin,
        item.bvc_price,
        item.margin.nil? ? '' : item.margin,
        client_item.client_price,
        client_item.margin.nil? ? '' : client_item.margin,
        client_item.client_price.nil? ? '' : client_item.price_to_points,
      ]
      row.unshift(item.category.msp_name) if options[:is_super_admin]
      row
    end
    def csv_row_for_client_manager(catalog_item, options)
      client_item= catalog_item.client_item
      item = client_item.item
      [
        item.id,
        item.title,
        item.category.parent.nil? ? '' : item.category.parent.title,
        item.category.nil? ? '' : item.category.title,
        item.preferred_supplier.mrp,
        client_item.client_price,
        client_item.client_price.nil? ? '' : client_item.price_to_points,
      ]
    end
  end
end

