class Cart < ActiveRecord::Base
  belongs_to :user_scheme
  has_many :cart_items

  def add_client_item(client_item)
    new_cart_item = CartItem.new(:client_item_id => client_item.id)
    existing_cart_item = cart_items.find { |cart_item| cart_item.client_item_id == new_cart_item.client_item_id }

    if existing_cart_item.present?
      existing_cart_item.increment
      return
    end
    cart_items << new_cart_item
  end

  def add_client_item_sms(client_item, client)
    otp_code_expiration = Client.find(client.id).otp_code_expiration
    if cart_items.last.present?
      cart_product_expiration = (Time.now - cart_items.last.created_at) 
    else
    cart_product_expiration =  0
    end

    if cart_product_expiration > otp_code_expiration
      cart_items.destroy_all
      check_otp_time = check_cart_item(client_item)
      return check_otp_time
    else
      check_otp_time = check_cart_item(client_item)
      return check_otp_time
    end
  end
  
  def check_cart_item(client_item)
    if cart_items.count < 1
      new_cart_item = CartItem.new(:client_item_id => client_item.id)
      cart_items << new_cart_item
    else
      return false
    end

  end

  def total_points
    cart_items.inject(0) { |total_points, cart_item| total_points + cart_item.total_price_in_points }.to_i
  end

  def empty?
    cart_items.nil? || cart_items.empty?
  end

  def remove_item(client_item)
    existing_cart_item = cart_items.find { |cart_item| cart_item.client_item_id == client_item.id }
    cart_items.destroy(existing_cart_item) if existing_cart_item.present?
  end

  def build_order_for(scheme, address_attributes={})
    address_attributes ||= {}
    order_items = cart_items.order("updated_at desc").collect { |cart_item|
      OrderItem.new(:client_item => cart_item.client_item,
                    :quantity => cart_item.quantity,
                    :points_claimed => cart_item.total_price_in_points,
                    :scheme => scheme,
                    :price_in_rupees => cart_item.total_price_in_points/user_scheme.user.client.points_to_rupee_ratio,
                    :bvc_margin => cart_item.client_item.item.margin,
                    :bvc_price => cart_item.client_item.item.bvc_price,
                    :channel_price => cart_item.client_item.item.channel_price,
                    :mrp => cart_item.client_item.item.mrp,
                    :supplier_id => cart_item.client_item.item.preferred_supplier.supplier.id)
    }
    Order.new(address_attributes.merge(:user => user_scheme.user, :order_items => order_items))
  end

  def clear
    cart_items.destroy_all
  end

  def size
    cart_items.count
  end
end
