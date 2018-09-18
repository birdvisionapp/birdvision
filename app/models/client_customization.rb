class ClientCustomization < ActiveRecord::Base
  
  belongs_to :client
  belongs_to :user_role
  attr_accessible :sign_up_enabled, :coupen_code_enabled, :user_role_id, :client_id, :image, :delete_image,
                  :additional_info_enabled, :field_title, :field_subtitle
  attr_accessor :delete_image
  has_attached_file :image, styles: { :medium=> "300x300>", :thumb => "100x100>"}
  has_paper_trail
  before_validation {image.clear if delete_image == "1"}
  validates :field_title, :presence => true, :if => :additional_info_enabled?
  validates :field_subtitle, :presence => true, :if => :additional_info_enabled?
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  
end
