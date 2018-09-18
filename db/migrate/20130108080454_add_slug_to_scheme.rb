class AddSlugToScheme < ActiveRecord::Migration
  def self.up
    add_column :schemes, :slug, :string
    Scheme.all.each do |scheme|
      scheme.slug = scheme.name.parameterize
      scheme.save
    end
  end

  def self.down
    remove_column :schemes, :slug
  end
end
