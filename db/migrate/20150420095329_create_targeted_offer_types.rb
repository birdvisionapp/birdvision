class CreateTargetedOfferTypes < ActiveRecord::Migration
  def change
    create_table :targeted_offer_types do |t|
      t.string   "offer_type_name"
      t.integer  "targeted_offer_config_id"
      t.integer  "template_id"
      t.timestamps
    end
  end
end
