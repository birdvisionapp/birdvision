class AddContactUsFieldsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :cu_email, :string
    add_column :clients, :cu_cc_email, :string
    add_column :clients, :cu_phone_number, :string
  end
end
