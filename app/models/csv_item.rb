class CsvItem

  def initialize()
   
  end

  def headers
    %w(item_id	mrp channel_price status title description)
  end

  def from_hash(attr_hash, existing_items)
    attr_hash.keep_if { |key, value| value.present? && headers.include?(key) }
    item = Csv::ItemBuilder.new(existing_items[item_id(attr_hash).to_i], attr_hash).build
    if item.present?
      item_supplier = Csv::ItemSupplierBuilder.new(item, attr_hash).build
      client_item = Csv::ClientItemBuilder.new(item, attr_hash).build
      return item
    end
  end

  def batch_from_hash(rows)
    item_ids = rows.collect { |row| item_id(row) }.compact
    items = Item.where("id IN (?) ", item_ids)
    if items.present?
      existing_items = Hash[*items.map { |i| [i.id, i] }.flatten]
      rows.collect { |row| from_hash(row, existing_items) if existing_items.present?}
    end
  end

  def unique_attribute
    "item_id"
  end

  private

  def item_id(attr_hash)
    attr_hash["item_id"]
  end

end
