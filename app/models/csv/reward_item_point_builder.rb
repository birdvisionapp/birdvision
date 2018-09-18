module Csv
  class RewardItemPointBuilder
    def initialize(reward_item, attrs)
      @reward_item = reward_item
      @attrs = attrs
    end

    def build
      attrs = @attrs.slice(*[:points].collect(&:to_s))
      attrs["points"] = attrs["points"].to_i
      reward_item_points = @reward_item.reward_item_points.build(:pack_size => "1",:metric => "units")
      reward_item_points.assign_attributes(attrs)
      reward_item_points
    end
  end
end