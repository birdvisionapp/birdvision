class CreateTargetedOfferValidities < ActiveRecord::Migration
  def change
    create_table :targeted_offer_validities do |t|
      t.integer  "targeted_offer_config_id"
      t.date     "start_date"
      t.date     "end_date"
      t.timestamps
    end
  end
end
