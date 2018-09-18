class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |table|
      table.string :client_name, :null => false, :default => ""
      table.float :points_to_rupee_ration
      table.string :contact_name
      table.string :contact_email
      table.string :contact_phone_number
      table.string :description
      table.string :notes

      table.timestamps

    end
    add_index :clients, :client_name, :unique => true

  end
end