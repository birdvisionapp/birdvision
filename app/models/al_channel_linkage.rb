class AlChannelLinkage < ActiveRecord::Base
  extend CSVImportable
  attr_accessible :retailer_code, :ro_code, :dealer_code, :user_id, :regional_manager_id
  # paginates_per 10
  
  #associations
  belongs_to :user
  belongs_to :regional_manager
  validates :retailer_code, presence: true
  validates :ro_code, presence: true
  validates :dealer_code, presence: true
  
  def self.parse_and_get_csv_details csv_file
    csv_table = self.parse_and_import_linkage_csv(csv_file, AlChannelLinkageCsv.new(AdminUser.first))
    if csv_table.headers.count > 1
      csv_table.each_slice(100).with_index do |rows, batch_index|
        csv_rows = rows.collect { |row| row.each { |key, col| col.try(:strip!) }.to_hash }
        create_objects_from_csv(csv_rows)
      end
    else
      raise Exceptions::File::InvalidCSVFormat
    end
  end

  def self.create_objects_from_csv(csv_rows)
    csv_rows.each do |row|
      AlChannelLinkageCsvParse.add_al_linkage(row["retailer_code"], row["ro_code"], row["dealer_codes"])
    end
  end
  
  def self.update_channel_linkage file
    parse_and_get_csv_details(file)
  end
  
end
