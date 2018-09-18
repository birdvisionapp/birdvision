class AssociateCategoryToDraftItems < ActiveRecord::Migration
  def change
    add_column :draft_items, :category_id, :integer
  end
end