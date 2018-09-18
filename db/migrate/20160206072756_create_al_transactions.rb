class CreateAlTransactions < ActiveRecord::Migration
  def change
    create_table :al_transactions do |t|
      t.string :user_id
      t.string :sap_code
      t.date :purchase_date
      t.string :sales_office_code
      t.string :sales_group_code
      t.string :dealer_hierarchy
      t.string :part_number
      t.integer :part_points
      t.integer :quantity
      t.string :total_points
      
      t.timestamps
    end
  end
end
