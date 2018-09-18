class AddColumnMspAndClientToTargetedOfferConfig < ActiveRecord::Migration
  def change
    add_column :targeted_offer_configs , :msp_id , :integer
    add_column :targeted_offer_configs , :client_id , :integer
  end
end
