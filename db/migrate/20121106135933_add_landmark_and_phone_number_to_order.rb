class AddLandmarkAndPhoneNumberToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :address_phone, :string
    add_column :orders, :address_landmark, :string

    Order.reset_column_information
    Order.destroy_all

    change_column :orders, :address_phone, :string, :null => false
  end
  def self.down
    remove_column :orders, :address_phone
    remove_column :orders, :address_landmark
  end
end
