class CreateMspTargetedOfferConfigs < ActiveRecord::Migration
  def change
    create_table :msp_targeted_offer_configs do |t|
      t.integer  "msp_id"
      t.integer  "targeted_offer_config_id"
      t.timestamps
    end
  end
end
