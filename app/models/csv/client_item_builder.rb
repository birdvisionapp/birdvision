module Csv
  class ClientItemBuilder
    def initialize(item, attrs)
      @item = item
      @attrs = attrs
    end

    def build
      attrs = @attrs.slice(*[:channel_price, :mrp, :status].collect(&:to_s))
      update_client_items(@item, attrs)
    end

    def update_client_items(item, price_attrs)
      channel_price = price_attrs["channel_price"].to_f
      mrp = price_attrs["mrp"].to_f
      status = price_attrs["status"]
      item.client_items.collect { |attr, val|
        client_item = attr
        return nil unless client_item.present?
        attrs = {}
        attrs.merge!(:client_price => ((Float(client_item.margin/100)*channel_price) + channel_price).round) if (client_item.margin.present? && channel_price.present?)
        is_deleted = false if (status.present? && status.downcase == 'active') || (mrp.present? && attrs[:client_price].present? && attrs[:client_price].to_f < mrp)
        is_deleted = true if (status.present? && status.downcase == 'inactive') || (mrp.present? && attrs[:client_price].present? && attrs[:client_price].to_f > mrp)
        attrs.merge!(:deleted => is_deleted) unless is_deleted.nil?
        client_item.assign_attributes(attrs)
        if client_item.deleted?
          client_item.catalog_items.each(&:delete)
          Sunspot.index!(client_item)
        end
        ClientItem.without_callback(:save, :before, :calculate_margin) do
          client_item.save(:validate => false)
        end
      }
    end
  end
end
