class AddExtraFieldToToTransaction < ActiveRecord::Migration
  def change
  	add_column :to_transactions , :delivered_at , :datetime
    add_column :to_transactions , :shipping_agent , :string
    add_column :to_transactions , :shipping_code , :string
    add_column :to_transactions , :sent_to_supplier_date , :datetime
    add_column :to_transactions , :sent_for_delivery , :datetime
  end
end
