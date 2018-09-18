class AddSlugToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :slug, :string
    Item.all.each do |item|
      item.slug = item.title.parameterize
      item.save
    end
  end

  def self.down
    remove_column :items, :slug
  end
end
