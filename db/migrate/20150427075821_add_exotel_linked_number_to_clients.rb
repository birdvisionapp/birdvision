class AddExotelLinkedNumberToClients < ActiveRecord::Migration
  def change
    add_column :clients, :exotel_linked_number, :string
  end
end
