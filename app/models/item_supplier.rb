class ItemSupplier < ActiveRecord::Base
  belongs_to :item
  belongs_to :supplier

  attr_accessible :item_id, :supplier_id, :geographic_reach, :delivery_time, :available_quantity,
                  :available_till_date, :mrp, :channel_price, :model_no, :listing_id, :supplier_margin,
                  :is_preferred
  has_paper_trail

  validates :mrp, :presence => true, :numericality => {:greater_than => 0, :allow_nil => true}
  validates :channel_price, :presence => true, :numericality => {:greater_than => 0, :allow_nil => true}
  validates :supplier_id, :uniqueness => {:scope => :item_id}

  after_save :update_margins

  def update_margins
    self.item.update_bvc_margin
    self.item.update_margin_in_client_catalog
  end

end