class ToTransaction < ActiveRecord::Base
  
  has_paper_trail

  belongs_to :to_applicable_user
  belongs_to :user
  belongs_to :targeted_offer_config
  belongs_to :incentive

  attr_accessible :user_id, :to_applicable_user_id, :targeted_offer_config_id, :incentive_id, :extra_points, :status, :delivered_at, :shipping_agent, :shipping_code, :sent_to_supplier_date, :sent_for_delivery, :address_name , :address_body, :address_city, :address_state, :address_zip_code, :address_phone, :address_landmark, :address_landline_phone, :participant_id, :targeted_offer_basis, :incentive_type, :unique_code
  
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

    after_transition :new => :sent_to_supplier do |to_gift, transition|
      to_gift.update_attributes(:sent_to_supplier_date => Time.now)
    end

    after_transition :sent_to_supplier => :delivery_in_progress do |to_gift, transition|
      to_gift.update_attributes(:sent_for_delivery => Time.now)
    end

    after_transition :delivery_in_progress => :delivered do |to_gift, transition|
      to_gift.update_attributes(:delivered_at => Time.now)
    end

    after_transition :sent_to_supplier => :delivery_in_progress do |to_gift, transition|
      begin
        OrderItemNotifier.to_notify_shipment(to_gift)
      rescue Exception => e
        Rails.logger.warn("Could not send Shipping confirmation email for To Gift #{to_gift.id} because of error #{e}")
      end
    end

    after_transition :delivery_in_progress => :delivered do |to_gift, transition|
      begin
        OrderItemNotifier.to_notify_delivery(to_gift)
      rescue Exception => e
        Rails.logger.warn("Could not send Delivery confirmation email for TO Gift #{to_gift.id} because of error #{e}")
      end
    end
  end

  def tracking_info_updatable?
    %w(sent_to_supplier delivery_in_progress).include? self.status
  end

  def tracking_info
    "#{self.shipping_agent} - #{self.shipping_code}" if self.shipping_agent.present? && self.shipping_code.present?
  end

  def self.valid_status_event? action
    status_events.include? action.to_sym
  end

  def to_complete_address_for_show
    [address_name, address_body, address_landmark, "#{address_city}-#{address_zip_code}", address_state, "Phone:#{address_phone}",
      address_landline_phone].reject{|v| v.blank?}.join(",<br>")
  end

 private

  def self.status_events
    ToTransaction.state_machines[:status].events.map(&:name)
  end

end
