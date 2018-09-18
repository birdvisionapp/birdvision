class Widget < ActiveRecord::Base
  attr_accessible :name, :description, :privileges
  
  has_many :client_managers, through: :client_managers_widgets
end
