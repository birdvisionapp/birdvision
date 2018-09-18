class AddColumnTargetedOfferConfigToTemplates < ActiveRecord::Migration
  def change
    add_column :templates , :targeted_offer_config_id , :integer
  end
end
