class CreateTargetedOfferConfigs < ActiveRecord::Migration
  def change
    create_table :targeted_offer_configs do |t|
      t.integer  "targeted_offer_validity_id"
      t.integer  "targeted_offer_config_incentive_id"
      t.string   "name"
      t.integer  "clients_template_id"
      t.boolean  "sms_based"
      t.boolean  "email_based"
      t.timestamps
    end
  end
end
