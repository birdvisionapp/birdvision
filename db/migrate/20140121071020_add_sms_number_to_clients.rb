class AddSmsNumberToClients < ActiveRecord::Migration
  def change
    add_column :clients, :sms_number, :string, :default => ''
  end
end
