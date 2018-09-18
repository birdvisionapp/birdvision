class AddSlugToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :slug, :string
    Category.all.each do |category|
      category.slug = category.name.parameterize
      category.save
    end
  end
end
