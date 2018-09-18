class CreateClientTargetedOfferConfigs < ActiveRecord::Migration
  def change
    create_table :client_targeted_offer_configs do |t|
      t.integer  "client_id"
      t.integer  "targeted_offer_config_id"
      t.timestamps
    end
  end
end
