class RemoveTargetedOfferConfigIdFromTargetedOfferTypes < ActiveRecord::Migration
  def change
    remove_column :targeted_offer_types, :targeted_offer_config_id
    remove_column :targeted_offer_types, :template_id
    add_column :targeted_offer_types, :description, :string 
  end
end
