module Csv
  class ItemBuilder
    def initialize(existing_item, attrs)
      @existing_item = existing_item
      @attrs = attrs
    end

    def build
      item = @existing_item
      attrs = @attrs.slice(*[:id, :status, :title, :description].collect(&:to_s))
      return nil if item.nil?
      channel_price = @attrs["channel_price"].to_f
      attrs.merge!(:bvc_price => ((Float(item.margin/100)*channel_price) + channel_price).round) if item.margin.present? && channel_price > 0
      item.assign_attributes(attrs)
      item
    end
  end
end
