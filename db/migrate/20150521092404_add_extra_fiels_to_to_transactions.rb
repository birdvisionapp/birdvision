class AddExtraFielsToToTransactions < ActiveRecord::Migration
  def change
  	add_column :to_transactions , :participant_id , :string
  	add_column :to_transactions , :targeted_offer_basis , :string
  	add_column :to_transactions , :incentive_type , :string
  end
end
