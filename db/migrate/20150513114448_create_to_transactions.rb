class CreateToTransactions < ActiveRecord::Migration
  def change
    create_table :to_transactions do |t|
      t.belongs_to :user
      t.belongs_to :to_applicable_user
      t.belongs_to :targeted_offer_config
      t.belongs_to :incentive
      t.integer :extra_points
      t.string :status
      t.timestamps
    end
  end
end
