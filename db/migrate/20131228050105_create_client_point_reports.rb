class CreateClientPointReports < ActiveRecord::Migration
  def change
    create_table :client_point_reports do |t|
      t.integer :client_id
      t.date :trans_date
      t.integer :credit, :default => 0
      t.integer :debit, :default => 0
      t.integer :balance, :default => 0

      t.timestamps
    end
    add_index :client_point_reports, :client_id
    add_index :client_point_reports, :trans_date    
  end
end
