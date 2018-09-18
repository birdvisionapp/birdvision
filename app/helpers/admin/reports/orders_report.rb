module Admin::Reports::OrdersReport

  def to_csv options = {}
    CSV.generate do |csv|
      csv << send("csv_header_for_#{options[:role]}", options)
      find_each(:batch_size => 6000) do |order_item|
        csv << send("csv_row_for_#{options[:role]}", order_item, options)
      end
    end
  end

  def csv_header_for_super_admin(options)
    header = ['Order ID', 'Order Item ID', 'Category', 'Sub Category', 'Item Id', 'Item Name', 'Listing Id', 'Supplier Name', 'Quantity', 'Participant Full Name',
      'Participant Username', 'Recipient name', 'Address', 'Landmark', 'City', 'Pincode', 'State', 'Mobile', 'Landline', 'Client', 'Scheme',
      'Status', 'Dispatched To Participant Date', 'Redeemed At Date', 'Points', 'MRP(Rs.)', 'Supplier Margin(%)', 'Channel Price(Rs.)', 'Base Price(Rs.)',
      'Base Margin(%)', 'Client Price(Rs.)', 'Client Margin(%)', 'Aging Total', 'Shipping Agent', 'Shipping Code', 'Reseller']
    header.unshift("MSP") if options[:is_super_admin]
    header
  end

  def csv_row_for_super_admin(order_item, options)
    order = order_item.order
    item = order_item.client_item.item

    row = [order.order_id, order_item.id, order_item.parent_category, item.category.title, item.id, item.title, item.preferred_supplier.listing_id,
      order_item.supplier.name, order_item.quantity, order.user.full_name, order.user.username, order.address_name, order.address_body, order.address_landmark, order.address_city,
      order.address_zip_code, order.address_state, order.address_phone, order.address_landline_phone, order.user.client_name, order_item.scheme.name, order_item.status_for_report,
      order_item.dispatched_to_participant_date=="" ? "" : order_item.dispatched_to_participant_date.strftime("%d-%b-%Y"), order_item.created_at.strftime("%d-%b-%Y"), order_item.points_claimed,
      order_item.mrp, order_item.supplier_margin, order_item.channel_price, order_item.bvc_price, order_item.bvc_margin, order_item.price_in_rupees/order_item.quantity, order_item.client_margin,
      order_item.distance_of_time_in_words, order_item.shipping_agent, order_item.shipping_code, order_item.reseller_name]
    row.unshift(order_item.scheme.client.msp_name) if options[:is_super_admin]
    row
  end

  # Removed 'Dispatched To Participant Date' CSV Header for time being, need to revert after some time.
  def csv_header_for_client_manager(options)
    ['Order ID', 'Order Item ID', 'Category', 'Sub Category', 'Item Id', 'Item Name', 'Quantity', 'Participant Full Name',
      'Participant Username', 'Recipient name', 'Address', 'Landmark', 'City', 'Pincode', 'State', 'Mobile', 'Landline', 'Scheme',
      'Status', 'Redeemed At Date', 'Points', 'MRP(Rs.)',
      'Client Price(Rs.)', 'Aging Total', 'Shipping Agent', 'Shipping Code']
  end

  def csv_row_for_client_manager(order_item, options)
    order = order_item.order
    item = order_item.client_item.item

    [order.order_id, order_item.id, order_item.parent_category, item.category.title, item.id, item.title,
      order_item.quantity, order.user.full_name, order.user.username, order.address_name, order.address_body, order.address_landmark, order.address_city,
      order.address_zip_code, order.address_state, order.address_phone, order.address_landline_phone, order_item.scheme.name, order_item.status_for_report,
      #order_item.dispatched_to_participant_date=="" ? "" : order_item.dispatched_to_participant_date.strftime("%d-%b-%Y"), # Follow Header for more info
      order_item.created_at.strftime("%d-%b-%Y"), order_item.points_claimed,
      order_item.mrp, order_item.price_in_rupees/order_item.quantity, order_item.distance_of_time_in_words, order_item.shipping_agent, order_item.shipping_code]
  end
end