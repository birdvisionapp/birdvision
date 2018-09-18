class AddHeroImageToScheme < ActiveRecord::Migration
  def self.up
    add_attachment :schemes, :hero_image
  end

  def self.down
    remove_attachment :schemes, :hero_image
  end
end
