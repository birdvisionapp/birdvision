class ChangeCurrencyColumnsFromFloatToDecimal < ActiveRecord::Migration
  def change
    change_column :items, :bvc_price, :decimal, {:precision => 20, :scale => 2}
    change_column :items, :margin, :decimal, {:precision => 20, :scale => 2}
    change_column :order_items, :price_in_rupees, :decimal, {:precision => 20, :scale => 2}
    change_column :order_items, :bvc_margin, :decimal, {:precision => 20, :scale => 2}
    change_column :order_items, :bvc_price, :decimal, {:precision => 20, :scale => 2}
    change_column :order_items, :channel_price, :decimal, {:precision => 20, :scale => 2}
    change_column :order_items, :mrp, :decimal, {:precision => 20, :scale => 2}
    change_column :client_items, :client_price, :decimal, {:precision => 20, :scale => 2}
    change_column :client_items, :margin, :decimal, {:precision => 20, :scale => 2}
    change_column :draft_items, :mrp, :decimal, {:precision => 20, :scale => 2}
    change_column :draft_items, :channel_price, :decimal, {:precision => 20, :scale => 2}
    change_column :draft_items, :supplier_margin, :decimal, {:precision => 20, :scale => 2}
    change_column :item_suppliers, :channel_price, :decimal, {:precision => 20, :scale => 2}
    change_column :item_suppliers, :supplier_margin, :decimal, {:precision => 20, :scale => 2}
    change_column :item_suppliers, :mrp, :decimal, {:precision => 20, :scale => 2}

  end
end
