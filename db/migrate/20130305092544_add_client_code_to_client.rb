class AddClientCodeToClient < ActiveRecord::Migration
  class Client < ActiveRecord::Base
    attr_accessible :code
  end
  def change
    add_column :clients, :code, :string

    Client.reset_column_information
    Client.all.each do |client|
      client.update_attributes!(:code => client.client_name.parameterize)
    end
  end
end
