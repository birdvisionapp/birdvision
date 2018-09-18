class AddClientToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.references :client
    end
  end
end
