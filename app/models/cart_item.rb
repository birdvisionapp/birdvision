class CartItem < ActiveRecord::Base
  attr_accessible :client_item_id, :cart_id, :quantity
  belongs_to :client_item
  belongs_to :cart
  validates :quantity, :numericality => {:only_integer => true, :greater_than => 0, :message => App::Config.errors[:cart][:cart_item][:invalid_quantity]}

  def increment
    update_quantity quantity.next
  end

  def extra_charges
    ExtraCharges.new(client_item, quantity)
  end

  def total_price_in_points
    (client_item.price_to_points * quantity) + extra_charges.total
  end
  
  def update_quantity quantity
    update_attributes(:quantity => quantity)
  end

end
