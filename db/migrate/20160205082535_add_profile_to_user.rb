class AddProfileToUser < ActiveRecord::Migration
  def change
    add_attachment :users, :avatar
    add_attachment :users, :extra_pic
    add_column :users, :extra_field, :string
  end
end
