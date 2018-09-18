class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.references :item, :null => false
      t.references :order, :null => false
    end
  end

end
