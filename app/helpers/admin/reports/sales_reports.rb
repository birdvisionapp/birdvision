module Admin::Reports::SalesReports

  def orders_report_of(order_items)
    columns_to_export = ["Order ID", "Order Item ID", "Item Name", "Quantity", "Participant", "Scheme", "Status", "Client Price", "Points"]
    CSV.generate do |csv|
      csv << columns_to_export
      order_items.each do |order_item|
        order = order_item.order
        item = order_item.client_item.item
        csv << [order.order_id, order_item.id, item.title, order_item.quantity, order.user.full_name, order_item.scheme.name,
                order_item.status.humanize, order_item.price_in_rupees, order_item.points_claimed]
      end
    end
  end

  def participants_report_of user_schemes
    columns_to_export = ["Scheme", "Participant Id", "Username", "Full Name", "Points uploaded", "Points redeemed", "Current Achievements", "Rewards Redeemed", "Category"]
    CSV.generate do |csv|
      csv << columns_to_export
      user_schemes.each do |user_scheme|
        user = user_scheme.user
        csv << [user_scheme.scheme.name, user.participant_id, user.username, user.full_name, user_scheme.total_points, user_scheme.redeemed_points, user_scheme.current_achievements, user_scheme.orders_total, user.role_display]
      end
    end
  end

end

