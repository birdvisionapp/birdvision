class CsvDraftItem

  def initialize(supplier)
    @supplier = supplier
  end

  def headers
    %w(title listing_id model_no mrp channel_price description available_quantity available_till_date)
  end

  def unique_attribute
    nil
  end

  def from_hash(attr_hash)
    hash = attr_hash.keep_if { |key, value| headers.include? key }
    draft_item = DraftItem.new(hash)
    draft_item.mrp = draft_item.mrp.round(2) if draft_item.mrp.present?
    draft_item.supplier = @supplier
    draft_item.geographic_reach = @supplier.geographic_reach
    draft_item.delivery_time = @supplier.delivery_time
    draft_item
  end

  def batch_from_hash(rows)
    rows.collect { |row| from_hash(row) }
  end
end