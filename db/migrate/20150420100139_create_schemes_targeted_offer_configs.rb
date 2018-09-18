class CreateSchemesTargetedOfferConfigs < ActiveRecord::Migration
  def change
    create_table :schemes_targeted_offer_configs do |t|
      t.integer  "scheme_id"
      t.integer  "targeted_offer_config_id"
      t.timestamps
    end
  end
end
