class AddRegistrationFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :participant_id, :string, :null => false, :default => ""
    add_column :users, :full_name, :string, :null => false, :default => ""
    add_column :users, :mobile_number, :string, :null => false, :default => ""
    add_column :users, :landline_number, :string, :null => false, :default => ""
    add_column :users, :address, :string
    add_column :users, :pincode, :string
    add_column :users, :client_name, :string, :null => false, :default => ""
    add_column :users, :notes, :string
  end
end
