module OrdersHelper
  def humanize_order_status status
    case status.to_sym
      when :new , :sent_to_supplier
        "Order Confirmed"
      when :delivery_in_progress
        "Shipped"
      when :delivered
        "Delivery Confirmed"
      when :incorrect
        "Cancelled"
      else
        status.humanize
    end
  end
end
