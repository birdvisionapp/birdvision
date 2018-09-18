class OrderItem < ActiveRecord::Base
  has_paper_trail

  extend Admin::Reports::OrdersReport

  attr_accessible :order, :quantity, :sent_to_supplier_date, :sent_for_delivery, :delivered_at, :points_claimed, :price_in_rupees,:order_approved,
                  :bvc_margin, :updated_at, :created_at, :client_item, :shipping_agent, :shipping_code, :scheme, :bvc_price, :channel_price, :mrp, :supplier_id
  belongs_to :order
  belongs_to :client_item
  belongs_to :scheme
  belongs_to :supplier

  scope :for_client, lambda { |client_id| joins(:scheme).where("schemes.client_id" => client_id) }
  scope :for_user_scheme, lambda { |user_scheme| joins(:order).where("orders.user_id = ?", user_scheme.user_id).joins(:scheme).where("order_items.scheme_id = ?", user_scheme.scheme_id) }
  scope :sent_to_supplier, -> { where(:status => :sent_to_supplier) }
  scope :delivery_in_progress, -> { where(:status => :delivery_in_progress) }
  scope :delivered, -> { where(:status => :delivered) }
  scope :incorrect, -> { where(:status => :incorrect) }
  scope :new_orders, -> { where(:status => :new) }
  scope :valid_orders, -> { where("order_items.status != 'incorrect'") }
  scope :created_within, lambda { |range| where(:created_at => range) }

  class OrderItemHelper
    include ActionView::Helpers::DateHelper
  end

  def helper
    @h ||= OrderItemHelper.new
  end

  def distance_of_time_in_words
    helper.distance_of_time_in_words created_at, time_to_delivery
  end


  state_machine :status, :initial => :new do

    event :send_to_supplier do
      transition :new => :sent_to_supplier
    end

    event :send_for_delivery do
      transition :sent_to_supplier => :delivery_in_progress
    end

    event :deliver do
      transition :delivery_in_progress => :delivered
    end

    event :incorrect do
      transition :new => :incorrect, :sent_to_supplier => :incorrect, :delivery_in_progress => :incorrect
    end

    event :refund do
      transition :incorrect => :refunded
    end

    after_transition :new => :sent_to_supplier do |order_item, transition|
      order_item.update_attributes(:sent_to_supplier_date => Time.now)
    end

    after_transition :sent_to_supplier => :delivery_in_progress do |order_item, transition|
      order_item.update_attributes(:sent_for_delivery => Time.now)
    end

    after_transition :delivery_in_progress => :delivered do |order_item, transition|
      order_item.update_attributes(:delivered_at => Time.now)
    end

    after_transition :sent_to_supplier => :delivery_in_progress do |order_item, transition|
      begin
        OrderItemNotifier.notify_shipment(order_item)
      rescue Exception => e
        Rails.logger.warn("Could not send Shipping confirmation email for OrderItem #{order_item.id} because of error #{e}")
      end
    end

    after_transition :delivery_in_progress => :delivered do |order_item, transition|
      begin
        OrderItemNotifier.notify_delivery(order_item)
      rescue Exception => e
        Rails.logger.warn("Could not send Delivery confirmation email for OrderItem #{order_item.id} because of error #{e}")
      end
    end

    after_transition :incorrect => :refunded do |order_item, transition|
      user_scheme = UserScheme.where(:user_id => order_item.order.user.id, :scheme_id => order_item.scheme.id).first
      user_scheme.update_attributes(:redeemed_points => user_scheme.redeemed_points - order_item.points_claimed)
      SchemeTransaction.record(user_scheme.scheme.id, SchemeTransaction::Action::REFUND, order_item.order, order_item.points_claimed)
      OrderItemNotifier.notify_refund(order_item, user_scheme)
      order_item.update_attributes(:points_claimed => 0, :price_in_rupees => 0)      
    end
  end


  def time_to_delivery
    delivered? ? delivered_at : Time.now
  end

  def self.valid_status_event? action
    status_events.include? action.to_sym
  end

  def parent_category
    (client_item.item.category.nil? || client_item.item.category.parent.nil?) ? "-" : client_item.item.category.parent.title
  end

  def status_for_report
    status.to_s.humanize
  end

  def dispatched_to_participant_date
    sent_for_delivery.present? ? sent_for_delivery : ''
  end

  def tracking_info_updatable?
    %w(sent_to_supplier delivery_in_progress).include? self.status
  end

  def tracking_info
    "#{self.shipping_agent} - #{self.shipping_code}" if self.shipping_agent.present? && self.shipping_code.present?
  end

  def client_margin
    client_price = price_in_rupees / quantity
    ((Float(client_price - channel_price) / channel_price)*100).round(2)
  end

  def supplier_margin
    ((Float(mrp - channel_price) / mrp) * 100).round(2)
  end

  def reseller_name
    client_resellers = order.user.client.client_resellers
    (client_resellers.present? and client_resellers.first.payout_start_date.end_of_day <= created_at.end_of_day) ? client_resellers.first.reseller.name : ""
  end

  def not_refunded?
    status != "refunded"
  end

  def total_points_claimed
    points_claimed - extra_charges.total
  end

  def extra_charges
    ExtraCharges.new(client_item, quantity)
  end

  private

  def self.status_events
    OrderItem.state_machines[:status].events.map(&:name)
  end

end
