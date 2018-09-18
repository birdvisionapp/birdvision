class ClientsTemplate < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :template_id, :client_id
  
  belongs_to :client
  belongs_to :template
end
