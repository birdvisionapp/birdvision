class ExtraCharges

  attr_accessor :client_item, :quantity

  def initialize(client_item, quantity = 1)
    @client_item = client_item
    @quantity = quantity
  end

  def display
    return_text = ""
    return_text << "Processing Fee@#{@client_item.item.category.service_charge}%: #{service_charge}, Service Tax@#{SERVICE_TAX}%: #{service_tax}" if is_service_charge?
    return_text << "#{(is_service_charge?) ? ', ' : ''}Delivery Charges: #{delivery_charges}" if is_delivery_charges?
    return_text
  end

  def total
    service_charge + service_tax + delivery_charges
  end

  private

  def service_charge
    return 0 unless is_service_charge?
    ((@client_item.price_to_points / 100 * @client_item.item.category.service_charge) * @quantity).to_f.round
  end

  def service_tax
    return 0 unless service_charge > 0
    (service_charge.to_f/100 * SERVICE_TAX).to_f.round
  end

  def delivery_charges
    (is_delivery_charges?) ? (@client_item.item.category.delivery_charges.to_f * points_ratio).round : 0
  end

  def is_service_charge?
    @client_item.item.category.service_charge.to_i > 0
  end

  def is_delivery_charges?
    @client_item.item.category.delivery_charges.to_i > 0
  end

  def points_ratio
    @client_item.client.points_to_rupee_ratio
  end

end