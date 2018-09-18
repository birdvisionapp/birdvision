class CreateClientPayments < ActiveRecord::Migration
  def change
    create_table :client_payments do |t|
      t.integer :client_invoice_id, :null => false
      t.string :bank_name
      t.string :payment_mode, :null => false
      t.string :transaction_reference
      t.date :paid_date, :null => false
      t.datetime :credited_at, :null => true
      t.decimal :amount_paid, :precision => 20, :scale => 2, :null => false
      t.timestamps
    end
    add_index :client_payments, :client_invoice_id
    add_index :client_payments, :paid_date
    add_index :client_payments, :credited_at
  end
end
