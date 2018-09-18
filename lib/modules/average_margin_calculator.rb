module AverageMarginCalculator
  def calculate_bvc_margin(items)
    aggregate_values = items.joins(:preferred_supplier).where("item_suppliers.channel_price != 0 AND bvc_price != 0").select("sum(item_suppliers.channel_price) as sum_channel_price, sum(bvc_price) as sum_bvc_price").first
    calculate_percentage(aggregate_values.sum_channel_price, aggregate_values.sum_bvc_price)
  end

  def client_margin_for_catalog_items(catalog_items)
    client_margin(catalog_items.joins(:client_item => {:item => :preferred_supplier}))
  end

  def client_margin_for_client_items(client_items)
    client_margin(client_items.joins(:item => :preferred_supplier))
  end

  private
  def calculate_percentage(sum_channel_price, sum_base_price)
    return 0.0 if sum_base_price.nil? || sum_channel_price.nil? || sum_channel_price <= 0
    sum_margin = sum_base_price - sum_channel_price
    (sum_margin*100.0/sum_channel_price).round(2)
  end

  def client_margin(collection)
    aggregate_values = collection.where("item_suppliers.channel_price != 0 AND bvc_price != 0 AND client_price != 0").select("sum(item_suppliers.channel_price) as sum_channel_price, sum(client_price) as sum_client_price").first
    calculate_percentage(aggregate_values.sum_channel_price, aggregate_values.sum_client_price)
  end
end