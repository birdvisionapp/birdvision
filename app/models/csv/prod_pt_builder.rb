module Csv
  class ProdPtBuilder
    def initialize(existing_reward_items, attrs)
      @attrs = attrs
      @existing_reward_items = existing_reward_items
    end

    def build
      reward_item = @existing_reward_items
      attrs = @attrs.slice(*[:al_part_no].collect(&:to_s))
      
      if reward_item.nil?
        reward_item = RewardItem.new(:client_id => ENV['AL_CLIENT_ID'].to_i, :scheme_id => ENV['AL_SCHEME_ID'].to_i, :name => attrs["al_part_no"], :status => "active") 
        reward_item.assign_attributes(attrs)
      end
      reward_item
    end
  end
end
