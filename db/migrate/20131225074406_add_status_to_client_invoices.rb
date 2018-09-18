class AddStatusToClientInvoices < ActiveRecord::Migration
  def change
    add_column :client_invoices, :status, :string, :default => 'pending'
    add_index :client_invoices, :status
  end
end
