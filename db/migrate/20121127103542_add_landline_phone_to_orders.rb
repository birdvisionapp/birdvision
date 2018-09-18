class AddLandlinePhoneToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :address_landline_phone, :string
    Order.reset_column_information
  end

  def self.down
    remove_column :orders, :address_landline_phone
  end
end