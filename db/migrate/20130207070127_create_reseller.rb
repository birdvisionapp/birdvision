class CreateReseller < ActiveRecord::Migration
  def change
    create_table :resellers do |t|
      t.string :name
      t.string :phone_number
      t.string :email
      t.date :payout_start_date
      t.integer :finders_fee
      t.timestamps
      t.references :admin_user
    end
    add_foreign_key "resellers", "admin_users", :name => "resellers_admin_user_id_fk"
  end
end
