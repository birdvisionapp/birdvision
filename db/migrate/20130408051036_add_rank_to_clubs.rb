class AddRankToClubs < ActiveRecord::Migration
  class Scheme < ActiveRecord::Base
    has_many :level_clubs
    has_many :clubs, :through => :level_clubs, :uniq => true
  end

  def change
    add_column :clubs, :rank, :integer

    Club.reset_column_information

    Scheme.all.each do |scheme|
      scheme.clubs.order(:id).each_with_index { |club, index|
        club.update_attributes!(:rank => index)
      }
    end
  end
end
