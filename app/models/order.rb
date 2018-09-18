class Order < ActiveRecord::Base
  attr_accessible :user, :address_name, :address_body, :address_city,
    :address_state, :address_zip_code, :address_phone, :address_landmark, :address_landline_phone,
    :order_items, :points, :redemption_type

  belongs_to :user
  has_many :order_items

  validates :address_name, :presence => true
  validates :address_body, :length => {:minimum => 6 }
  validates :address_city, :address_state, :presence => true
  validates :address_zip_code,
    :format => {:with => /^\d{6}$/}
  validates :address_phone, :presence => true,
    :numericality => {:only_integer => true, :allow_blank => true},
    :length => {:is => 10, :allow_blank => true}

  scope :for_scheme, lambda { |scheme| joins(:order_items).where('order_items.scheme_id' => scheme) }

  paginates_per 10

  def place_order(user_scheme)
    order_placed = false
    transaction do
      return false unless user_scheme.can_place_order?
      self.points = total
      order_placed = self.save
      if order_placed
        user_scheme.redeem()
        SchemeTransaction.record(user_scheme.scheme.id, SchemeTransaction::Action::DEBIT, self, total)
      end
    end
    order_placed
  end

  def total
    order_items.inject(0) { |total_points, order_items| total_points + order_items.points_claimed }
  end

  def complete_address_for_show
    [address_name, address_body, address_landmark, "#{address_city}-#{address_zip_code}", address_state, "Phone:#{address_phone}",
      address_landline_phone].reject{|v| v.blank?}.join(",<br>")
  end

  def order_id
    "ORD#{id}"
  end
end