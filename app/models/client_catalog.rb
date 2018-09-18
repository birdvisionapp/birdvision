class ClientCatalog < ActiveRecord::Base
  has_one :client, :inverse_of => :client_catalog
  has_many :client_items

  has_paper_trail

end