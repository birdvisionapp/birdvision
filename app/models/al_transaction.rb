class AlTransaction < ActiveRecord::Base
  extend CSVImportable
  extend Admin::Reports::AlTransactionReport
  paginates_per 10
  
  attr_accessible :user_id, :sap_code, :purchase_date, :sales_office_code, :sales_group_code, :dealer_hierarchy, :part_number, :part_points, :quantity, :total_points, :reward_item_point_id
  belongs_to :reward_item_point
  belongs_to :user
  
  def self.parse_and_get_csv_details csv_file
    csv_table = self.parse_and_import_sap_csv csv_file
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
      AshokCsvParse.check_user_points(row["Date"], row["Sales Office Code"], row["Sales Group Code"], row["SAP Code"], row["Dealer Hierarchy"], row["Part Number"], row["Quantity"])
    end
  end

  def self.update_points_for_sap_user file
    parse_and_get_csv_details(file)
  end
  
  def self.add_product_points_from_csv csv_file
    client = Client.find(ENV['AL_CLIENT_ID'].to_i)
    self.import_from_file(csv_file, CsvRewardProductPoint.new(client))
  end
end