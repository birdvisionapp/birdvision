class Threshold < ActiveRecord::Base
  
  belongs_to :client_manager
  attr_accessible :low, :medium, :high, :low_color, :medium_color, :high_color, :client_manager_id
end
