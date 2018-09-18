class RemoveUnusedColumnsFromTargetedOfferConfigs < ActiveRecord::Migration
  def change
    remove_column :targeted_offer_configs, :targeted_offer_config_incentive_id
    remove_column :targeted_offer_configs, :clients_template_id
  end
end