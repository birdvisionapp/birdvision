class AddCurrencyToClient < ActiveRecord::Migration
  def change
    add_column :clients, :currency, :string
  end
end
