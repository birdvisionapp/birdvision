class AddAgeRangeColumnsToTargetedOfferConfigs < ActiveRecord::Migration
  def change
    add_column :targeted_offer_configs , :start_age , :integer
    add_column :targeted_offer_configs , :end_age , :integer
  end
end
