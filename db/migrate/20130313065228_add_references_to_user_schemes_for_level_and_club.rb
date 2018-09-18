class AddReferencesToUserSchemesForLevelAndClub < ActiveRecord::Migration
  class UserScheme < ActiveRecord::Base
    attr_accessible :level_id, :club_id
    belongs_to :scheme
  end

  def change
    rename_column :user_schemes, :level, :level_name
    rename_column :user_schemes, :club, :club_name

    change_table :user_schemes do |table|
      table.references :level, :null => true
      table.references :club, :null => true
    end
    add_foreign_key :user_schemes, :levels, :name => "user_schemes_level_id_fk"
    add_foreign_key :user_schemes, :clubs, :name => "user_schemes_club_id_fk"

    UserScheme.reset_column_information
    Scheme.reset_column_information
    UserScheme.includes(:scheme).where("schemes.single_redemption = ?", true).each { |user_scheme|
      attrs = {}
      attrs.merge!(:club_id => Club.with_scheme_and_club_name(user_scheme.scheme, user_scheme.club_name).first.id) if user_scheme.club_name.present?
      attrs.merge!(:level_id => Level.with_scheme_and_level_name(user_scheme.scheme, user_scheme.level_name).first.id) if user_scheme.level_name.present?
      user_scheme.update_attributes!(attrs) if attrs.present?
    }
  end
end
