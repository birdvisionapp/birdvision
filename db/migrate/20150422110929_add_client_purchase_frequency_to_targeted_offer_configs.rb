class AddClientPurchaseFrequencyToTargetedOfferConfigs < ActiveRecord::Migration
  def change
    add_column :targeted_offer_configs, :client_purchase_frequency, :integer
  end
end
