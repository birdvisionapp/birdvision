class ClientReseller < ActiveRecord::Base
  belongs_to :client
  belongs_to :reseller
  has_many :slabs

  accepts_nested_attributes_for :slabs
  has_paper_trail

  attr_accessible :finders_fee, :payout_start_date, :client_id, :reseller_id, :slabs_attributes, :slabs, :assigned, :payout_end_date
  validates :reseller_id, :presence => true
  validates :client_id, :presence => true
  validate :client_reseller_valid?
  validates :finders_fee, :presence => true, :numericality => {:greater_than => 0, :allow_nil => true}
  validates :payout_start_date, :presence => true

  # Scopes
  scope :for_client, lambda {|client_id, reseller_id| where(client_id: client_id, reseller_id: reseller_id)}

  def payout
    sales_total_for_client = sales
    slab = self.slabs.sort_by(&:lower_limit).select { |slab| slab.lower_limit <= sales_total_for_client }
    slab.present? ? ((slab.max_by(&:lower_limit).payout_percentage/100) * sales_total_for_client).to_i : 0
  end

  def sales
    order_items_in_payout_range.valid_orders.sum(:price_in_rupees).to_i
  end

  def order_items_in_payout_range
    end_date = payout_end_date.presence || Date.today
    OrderItem.for_client(client_id).created_within(payout_start_date.beginning_of_day..end_date.end_of_day)
  end

  def client_reseller_valid?
    errors.add(:client_id, :existing) if (id.nil? and (ClientReseller.where(:client_id => self.client_id, :assigned => true).any? ))
    errors.add(:client_id, :reassign) if (id.nil? and (ClientReseller.where(:client_id => self.client_id, :reseller_id => self.reseller_id, :assigned => false).any? ))
  end

end