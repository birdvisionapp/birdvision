class ClientManagersWidget < ActiveRecord::Base
  attr_accessible :widget_id, :client_manager_id, :position

  belongs_to :widget
  belongs_to :client_manager

  validates :widget_id, :presence => true
  validates :client_manager_id, :presence => true
end