class ChangeClubBasedToSingleRedemption < ActiveRecord::Migration
  class Scheme < ActiveRecord::Base
    attr_accessible :scheme_type, :single_redemption
    module Type
      POINT_BASED = "point_based"
      CLUB_BASED = "club_based"
      ALL = [POINT_BASED, CLUB_BASED]
    end
  end

  def change
    add_column :schemes, :single_redemption, :boolean, :default => false
    Scheme.reset_column_information
    Scheme.all.each { |scheme| scheme.update_attributes!(:single_redemption => true) if scheme.scheme_type == Scheme::Type::CLUB_BASED }
    remove_column :schemes, :scheme_type
  end
end
