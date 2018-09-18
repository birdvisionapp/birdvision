class AddAttachmentImageToItems < ActiveRecord::Migration
  def self.up
    change_table :items do |t|
      t.has_attached_file :image
    end
    remove_column :items, :image_url
  end

  def self.down
    drop_attached_file :items, :image
    add_column :items, :image_url, :string
  end
end
