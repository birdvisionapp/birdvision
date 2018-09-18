module Admin::Reports::ClientReport
  include Admin::Reports::SchemeReport

  def to_csv options = {}
    generate_csv(find(:first), CSV_HEADERS, options)
  end

  private
  def generate_csv(client, columns_to_export, options)
    columns_to_export.unshift("MSP") if options[:is_super_admin]
    CSV.generate do |csv|
      csv << columns_to_export
      client.schemes.each do |scheme|
        reporting_data_of_users_for(scheme, options).each { |row|
          csv << row
        }
      end
    end
  end

end