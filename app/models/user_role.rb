class UserRole < ActiveRecord::Base
  
  attr_accessible :ancestry, :client_id, :name, :color_hex, :sub_roles_attributes

  has_ancestry
  
  # Associations
  has_one :client_customization
  belongs_to :client
  has_many :users

  has_many :sub_roles, :class_name => 'UserRole', :foreign_key => :ancestry
  
  accepts_nested_attributes_for :sub_roles, allow_destroy: true

  # Scopes
  scope :main_roles, -> { where(:ancestry => nil) }
  scope :sub_roles, -> { where(arel_table[:ancestry].not_eq(nil)).reorder("ancestry") }
  scope :for_client, lambda {|client_id| where(:client_id => client_id)}
  scope :for_name, lambda {|name| where('lower(name) = ?', name.downcase) if name.present? }
  scope :select_options, select([:id, :name, :client_id, :ancestry]).order(:client_id)
 
  # Validations
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false, :scope => :client_id}

  # CallBacks
  before_save :set_client_assoc

  def display_with_client
    unless client.nil?
      "#{client.client_name} > #{name}"  
    end
  end

  def display_name
    main? ? self.name : "#{self.parent.name} > #{self.name}"
  end

  def main?
    self.parent.nil? || false
  end

  private

  def set_client_assoc
    if self.sub_roles.present?
      self.sub_roles.each {|sub|
        sub.client_id = client.id
        sub.save
      }
    end
  end

end
