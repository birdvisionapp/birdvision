class OrderNotifier
  def self.notify_confirmation(order, user_scheme)
    total_points = order.total
    OrderMailer.delay.point_redemption(order, user_scheme.scheme, order.order_items, total_points) if order.user.email.present?
    return nil if order.user.mobile_number.blank?
    if user_scheme.show_points?
      SmsMessage.new(:point_order_confirmation, :to => user_scheme.user.mobile_number, :order_id => order.order_id, :total_points => total_points, :client => order.user.client.client_name).delay.deliver
    else
      SmsMessage.new(:club_order_confirmation, :to => user_scheme.user.mobile_number, :order_id => order.order_id, :client => order.user.client.client_name).delay.deliver
    end
  end
end