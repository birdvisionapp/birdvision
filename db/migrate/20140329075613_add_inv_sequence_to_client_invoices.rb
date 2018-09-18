class AddInvSequenceToClientInvoices < ActiveRecord::Migration
  
  def up
    add_column :client_invoices, :inv_sequence, :integer
    add_column :client_invoices, :deleted, :boolean, :default => false
    add_index :client_invoices, :inv_sequence
    add_index :client_invoices, :deleted
    
    client_invoices = ClientInvoice.confirmed
    client_invoices.each do |invoice|
      invoice.update_attribute(:inv_sequence, invoice.id)
    end
  end

  def down
    remove_column :client_invoices, :inv_sequence, :integer
    remove_column :client_invoices, :deleted, :boolean, :default => false
  end

end
