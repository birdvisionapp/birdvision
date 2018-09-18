class ConvertExistingSchemesToLevelClubSchemes < ActiveRecord::Migration
  class UserScheme < ActiveRecord::Base
    attr_accessible :level_id, :club_id
    belongs_to :scheme
  end

  class Club < ActiveRecord::Base
    attr_accessible :name
    has_one :level_club
  end

  class Scheme < ActiveRecord::Base
    has_many :level_clubs
    has_many :levels, :through => :level_clubs, :uniq => true
    has_many :clubs, :through => :level_clubs, :uniq => true
    has_many :user_schemes

    def active_items
      ClientItem.joins(:catalog_items).where("catalog_items.catalog_owner_type = ? AND catalog_items.catalog_owner_id = ?", "Scheme", id).where("client_items.client_price IS NOT NULL AND client_items.deleted = ?", false)
    end

  end

  class LevelClub < ActiveRecord::Base
    belongs_to :club, :validate => true
    belongs_to :level, :validate => true
    belongs_to :scheme
    attr_accessible :level, :club, :scheme

    def name
      "#{level.name.humanize}-#{club.name.humanize}"
    end

    def catalog
      Catalog.new(name, catalog_items)
    end
  end

  def create_level_clubs(scheme, level_names, club_names)
    return unless level_names.present? && club_names.present?
    levels = level_names.collect { |level| Level.new(:name => level) }
    clubs = club_names.collect.with_index { |club, rank| Club.new(:name => club) }

    levels.each { |level|
      clubs.each { |club|
        scheme.level_clubs.build(:club => club, :level => level, :scheme => scheme)
      }
    }
  end

  class CatalogItem < ActiveRecord::Base
    attr_accessible :client_item, :catalog_owner_type, :catalog_owner_id

    belongs_to :client_item
  end

  def change
    UserScheme.reset_column_information
    Scheme.where(:single_redemption => false).each { |scheme|
      create_level_clubs(scheme, %w(level), %w(club))
      scheme.save!
      scheme.level_clubs.each { |level_club|
        scheme.active_items.each { |client_item|
          CatalogItem.create!(:client_item => client_item, :catalog_owner_id => level_club.id, :catalog_owner_type => 'LevelClub')
        }
      }
    }

    UserScheme.includes(:scheme).where("schemes.single_redemption = ?", false).each { |user_scheme|
      user_scheme.update_attributes!(:club_id => user_scheme.scheme.clubs.first.id, :level_id => user_scheme.scheme.levels.first.id)
    }

  end
end
