class OrderItemNotifier
  def self.notify_shipment(order_item)
    order = order_item.order
    OrderItemMailer.delay.shipped(order_item, {claimed_points: order_item.points_claimed, points: order_item.total_points_claimed}) if order.user.email.present?
    return nil if order.user.mobile_number.blank?
    if order_item.tracking_info.present?
      SmsMessage.new(:tracked_order_shipment, :to => order.user.mobile_number, :order_id => order.order_id, :item => order_item.client_item.item.title, :tracking_info => order_item.tracking_info, :client => order.user.client.client_name, :order_item_id => order_item.id).delay.deliver
    else
      SmsMessage.new(:untracked_order_shipment, :to => order.user.mobile_number, :order_id => order.order_id, :item => order_item.client_item.item.title, :client => order.user.client.client_name, :order_item_id => order_item.id).delay.deliver
    end
  end

  def self.notify_delivery(order_item)
    order = order_item.order
    OrderItemMailer.delay.delivered(order_item, {claimed_points: order_item.points_claimed, points: order_item.total_points_claimed}) if order.user.email.present?
    return nil if order.user.mobile_number.blank?
    if order_item.tracking_info.present?
      SmsMessage.new(:tracked_order_delivery, :to => order.user.mobile_number, :order_id => order.order_id, :item => order_item.client_item.item.title, :tracking_info => order_item.tracking_info, :client => order.user.client.client_name, :order_item_id => order_item.id).delay.deliver
    else
      SmsMessage.new(:untracked_order_delivery, :to => order.user.mobile_number, :order_id => order.order_id, :item => order_item.client_item.item.title, :client => order.user.client.client_name, :order_item_id => order_item.id).delay.deliver
    end
  end

  def self.to_notify_shipment(gift)
    config = gift.targeted_offer_config.id
    gift_name = Incentive.where(:targeted_offer_configs_id => config).first.incentive_detail
    OrderItemMailer.delay.to_shipped(gift, gift_name) if gift.user.email.present?
    return nil if gift.user.mobile_number.blank?
    if gift.tracking_info.present?
      SmsMessage.new(:to_tracked_order_shipment, :to => gift.user.mobile_number, :user => gift.user.full_name, :gift => gift_name, :shipping_agent => gift.shipping_agent, :shipping_code => gift.shipping_code, :client => gift.user.client.client_name).delay.deliver
    else
      SmsMessage.new(:to_untracked_order_shipment_delivery, :to => gift.user.mobile_number, :user => gift.user.full_name, :gift => gift_name, :client => gift.user.client.client_name).delay.deliver
    end
  end

  def self.to_notify_delivery(gift)
    config = gift.targeted_offer_config.id
    gift_name = Incentive.where(:targeted_offer_configs_id => config).first.incentive_detail
    OrderItemMailer.delay.to_delivered(gift, gift_name) if gift.user.email.present?
     return nil if gift.user.mobile_number.blank?
    if gift.tracking_info.present?
       SmsMessage.new(:to_tracked_order_delivery, :to => gift.user.mobile_number, :user => gift.user.full_name, :gift => gift_name, :client => gift.user.client.client_name).delay.deliver
     else
       SmsMessage.new(:to_untracked_order_delivery, :to => gift.user.mobile_number, :user => gift.user.full_name, :gift => gift_name, :client => gift.user.client.client_name).delay.deliver
     end
  end

  def self.notify_refund(order_item, user_scheme)
    order = order_item.order
    points = order_item.points_claimed
    OrderItemMailer.delay.refunded(order_item, {claimed_points: points, points: order_item.total_points_claimed}) if order.user.email.present?
    return nil if order.user.mobile_number.blank?
    if user_scheme.scheme.show_points?
      SmsMessage.new(:order_item_refund, :to => order.user.mobile_number, :order_id => order.order_id, :item => order_item.client_item.item.title, :points => points, :client => order.user.client.client_name, :order_item_id => order_item.id).delay.deliver
    else
      SmsMessage.new(:single_redemption_refund, :to => order.user.mobile_number, :order_id => order.order_id, :item => order_item.client_item.item.title, :client => order.user.client.client_name, :order_item_id => order_item.id).delay.deliver
    end
  end
end