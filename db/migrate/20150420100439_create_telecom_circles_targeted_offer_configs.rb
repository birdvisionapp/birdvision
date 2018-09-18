class CreateTelecomCirclesTargetedOfferConfigs < ActiveRecord::Migration
  def change
    create_table :telecom_circles_targeted_offer_configs do |t|
      t.integer  "telecom_circle_id"
      t.integer  "targeted_offer_config_id"
      t.timestamps
    end
  end
end
