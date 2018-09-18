class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string  :name,    :null=>false
      t.text    :address
      t.string  :city
      t.string  :state
      t.string  :pin
      t.timestamps
    end
  end
end
