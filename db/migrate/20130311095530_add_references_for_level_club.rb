class AddReferencesForLevelClub < ActiveRecord::Migration
  class LevelClub < ActiveRecord::Base
    belongs_to :scheme
    belongs_to :level
    belongs_to :club
  end

  class Club < ActiveRecord::Base
    attr_accessible :name
    has_one :level_club
  end

  def change
    change_table :level_clubs do |table|
      table.references :level, :null => true
      table.references :club, :null => true

    end
    LevelClub.reset_column_information

    LevelClub.all.each { |level_club|
      if LevelClub.joins(:level).where("level_clubs.scheme_id = ? AND levels.name = ?", level_club.scheme_id, level_club.level_name).exists?
        level_club.level = LevelClub.joins(:level).where("level_clubs.scheme_id = ? AND levels.name = ?", level_club.scheme_id, level_club.level_name).first.level
      else
        level_club.create_level(:name => level_club.level_name)
      end

      if LevelClub.joins(:club).where("level_clubs.scheme_id = ? AND clubs.name = ?", level_club.scheme_id, level_club.club_name).exists?
        level_club.club = LevelClub.joins(:club).where("level_clubs.scheme_id = ? AND clubs.name = ?", level_club.scheme_id, level_club.club_name).first.club
      else
        level_club.create_club(:name => level_club.club_name)
      end
      level_club.save!
    }

    remove_column :level_clubs, :level_name
    remove_column :level_clubs, :club_name
    add_foreign_key "level_clubs", "levels", :name => "level_clubs_level_id_fk"
    add_foreign_key "level_clubs", "clubs", :name => "level_clubs_club_id_fk"

    add_index :level_clubs, [:level_id, :club_id], :unique => true

    change_column :level_clubs, :level_id, :integer, :null => false
    change_column :level_clubs, :club_id, :integer, :null => false
  end
end
