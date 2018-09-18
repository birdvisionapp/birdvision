class CreateTargetedOfferConfigIncentives < ActiveRecord::Migration
  def change
    create_table :targeted_offer_config_incentives do |t|
      t.integer  "targeted_offer_config_id"
      t.integer  "incentive_id"
      t.string   "incentive_on"
      t.integer  "targted_offer_config_id"
      t.timestamps
    end
  end
end