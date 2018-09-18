class AddCustomThemeToClient < ActiveRecord::Migration
  def self.up
    add_attachment :clients, :custom_theme
  end

  def self.down
    remove_attachment :clients, :custom_theme
  end
end
