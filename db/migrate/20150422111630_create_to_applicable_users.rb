class CreateToApplicableUsers < ActiveRecord::Migration
  def change
    create_table :to_applicable_users do |t|
      t.belongs_to :targeted_offer_config
      t.belongs_to :user
      t.integer :user_purchase_frequency, :integer
      t.boolean :to_availed
      t.timestamps
    end
  end
end
