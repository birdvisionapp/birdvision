module Csv
  class ItemSupplierBuilder
    def initialize(item, attrs)
      @item = item
      @attrs = attrs
    end

    def build
      attrs = @attrs.slice(*[:channel_price, :mrp].collect(&:to_s))
      item_supplier = @item.preferred_supplier
      return nil unless item_supplier.present? && (attrs["mrp"].present? || attrs["channel_price"].present?)
      attrs.merge!(:supplier_margin =>  ((Float(attrs["mrp"].to_f - attrs["channel_price"].to_f) / attrs["mrp"].to_f) * 100).round(2))
      item_supplier.assign_attributes(attrs)
      ItemSupplier.without_callback(:save, :after, :update_margins) do
        item_supplier.save
      end
    end
  end
end
