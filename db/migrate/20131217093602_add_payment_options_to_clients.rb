class AddPaymentOptionsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :is_locked, :boolean, :default => false
    add_column :clients, :ots_charges, :decimal, :precision => 20, :scale => 2
    add_column :clients, :is_fixed_amount, :boolean, :default => false
    add_column :clients, :fixed_amount, :decimal, :precision => 20, :scale => 2
    add_column :clients, :is_participant_rate, :boolean, :default => false
    add_column :clients, :participant_rate, :decimal, :precision => 20, :scale => 2
    add_column :clients, :paid_points, :integer, :default => 0
    add_column :clients, :puc_rate, :decimal, :precision => 20, :scale => 2
    add_index :clients, :is_locked
  end
end
