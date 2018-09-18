class AddAddressFieldsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :address_name, :string
    add_column :orders, :address_body, :text
    add_column :orders, :address_city, :string
    add_column :orders, :address_state, :string
    add_column :orders, :address_zip_code, :string

    Order.reset_column_information
    Order.destroy_all

    change_column :orders, :address_name, :string, :null => false
    change_column :orders, :address_body, :text, :null => false
    change_column :orders, :address_city, :string, :null => false
    change_column :orders, :address_state, :string, :null => false
    change_column :orders, :address_zip_code, :string, :null => false
  end
  def self.down
    remove_column :orders, :address_name
    remove_column :orders, :address_body
    remove_column :orders, :address_city
    remove_column :orders, :address_state
    remove_column :orders, :address_zip_code
  end
end
