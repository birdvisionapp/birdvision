class AddClientTypeToClient < ActiveRecord::Migration
  class Client < ActiveRecord::Base
    module Type
      POINT_BASED = "point_based"
      CLUB_BASED = "club_based"
      ALL = [POINT_BASED, CLUB_BASED]
    end

  end

  def change
    add_column :clients, :client_type, :string, :null => false, :default => Client::Type::POINT_BASED
    change_column_default(:clients, :client_type, nil)
  end
end
