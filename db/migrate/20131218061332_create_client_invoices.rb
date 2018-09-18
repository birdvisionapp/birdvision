class CreateClientInvoices < ActiveRecord::Migration
  def change
    create_table :client_invoices do |t|
      t.integer :client_id, :null => false
      t.string :invoice_type, :null => false
      t.text :amount_breakup
      t.date :invoice_date
      t.date :due_date, :null => true
      t.integer :points, :default => 0
      t.timestamps
    end
    add_index :client_invoices, :client_id
    add_index :client_invoices, :invoice_type
    add_index :client_invoices, :invoice_date
  end
end
