class AddPaperclipToClientCustomizations < ActiveRecord::Migration
  def change
    add_attachment :client_customizations, :image
  end
end
