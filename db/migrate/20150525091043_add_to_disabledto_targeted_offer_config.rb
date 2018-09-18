class AddToDisabledtoTargetedOfferConfig < ActiveRecord::Migration
  def up
    add_column :targeted_offer_configs, :to_disabled, :string, default: 'enabled'
  end

  def down
    remove_column :targeted_offer_configs, :to_disabled
  end
end
