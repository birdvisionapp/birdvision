class AddTypeForAScheme < ActiveRecord::Migration
  class Scheme < ActiveRecord::Base
    attr_accessible :scheme_type
    module Type
      POINT_BASED = "point_based"
      CLUB_BASED = "club_based"
      ALL = [POINT_BASED, CLUB_BASED]
    end
    belongs_to :client
  end
  def change
    add_column :schemes, :scheme_type, :string, :null => false, :default => Scheme::Type::POINT_BASED
    change_column_default(:schemes, :scheme_type, nil)
    Scheme.reset_column_information
    Scheme.all.each { |scheme| scheme.update_attributes!(:scheme_type => scheme.client.client_type) }
  end
end