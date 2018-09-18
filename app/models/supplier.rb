class Supplier < ActiveRecord::Base

  attr_accessible :name, :phone_number, :address, :geographic_reach, :supplied_categories, :additional_notes,
                  :description, :delivery_time, :payment_terms, :msp_id
  has_paper_trail

  belongs_to :msp

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false, :scope => :msp_id}
  validates :delivery_time, :presence => true
  validates :payment_terms, :presence => true
  validates :geographic_reach, :presence => true

  # Scope
  scope :select_options, select([:id, :name]).order(:name)


  def msp_name
    (msp) ? msp.name : "-"
  end

end
