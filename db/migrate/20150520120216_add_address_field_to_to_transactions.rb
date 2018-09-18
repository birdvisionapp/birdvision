class AddAddressFieldToToTransactions < ActiveRecord::Migration
  def change
  	add_column :to_transactions , :address_name , :string
  	add_column :to_transactions , :address_body , :text
  	add_column :to_transactions , :address_city , :string
  	add_column :to_transactions , :address_state , :string
  	add_column :to_transactions , :address_zip_code , :string
  	add_column :to_transactions , :address_phone , :string
    add_column :to_transactions , :address_landmark , :string
    add_column :to_transactions , :address_landline_phone , :string
  end
end
