class AddExtraOptionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :extra_options, :text
  end
end
