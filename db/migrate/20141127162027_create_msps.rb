class CreateMsps < ActiveRecord::Migration
  def change
    create_table :msps do |t|
      t.string :name
      t.string :contact_name
      t.string :phone_number
      t.string :email
      t.text :address
      t.decimal :opening_balance, :precision => 20, :scale => 2
      t.decimal :setup_charge, :precision => 20, :scale => 2
      t.decimal :fixed_amount, :precision => 20, :scale => 2
      t.text :plan_details
      t.text :notes
      t.string :status, :default => "active"
      t.timestamps
    end
    
  end
end
