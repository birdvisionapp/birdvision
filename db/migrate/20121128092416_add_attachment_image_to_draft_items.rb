class AddAttachmentImageToDraftItems < ActiveRecord::Migration
  def self.up
    add_attachment :draft_items, :image
  end

  def self.down
    remove_attachment :draft_items, :image
  end
end
