class ChangeSpecificationToTextForDraftItems < ActiveRecord::Migration
  def change
    change_column :draft_items, :specification, :text, :limit => 30000
  end
end
