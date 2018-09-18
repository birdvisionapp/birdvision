require 'csv'

module CSVImportable
  def import_from_file(csv_file, entity)
    import_from_content(csv_file.read, entity)
  end

  def import_from_content(csv_content, entity)
    csv_table = parse_csv_content(csv_content)
    check_headers(csv_table.headers, entity.headers)
    check_for_duplicates(csv_table, entity.unique_attribute)
    create_objects_from(csv_table, entity)
  end

  def parse_and_import_sap_csv(csv_file)
    csv_content = csv_file.read
    csv_table = parse_csv_content(csv_content)
  end
  
  def parse_and_import_linkage_csv(csv_file, entity)
    csv_content = csv_file.read
    csv_table = parse_csv_content(csv_content)
    check_headers(csv_table.headers, entity.headers)
    csv_table
  end
  
  private
  def parse_csv_content(csv_file_content)
    begin
      text = csv_file_content.encode('UTF-8', :invalid => :replace, :replace => '', :undef => :replace)
      CSV.parse(text, :headers => true, :skip_blanks => true)
    rescue
      raise Exceptions::File::InvalidFileType
    end
  end

  def check_headers(csv_headers, expected_headers)
    raise Exceptions::File::InvalidCSVFormat unless expected_headers.sort == csv_headers.sort
  end

  def create_objects_from(csv_table, entity)
    ActiveRecord::Base.transaction do
      valid_objects = []
      erroneous_objects = {}
      csv_table.each_slice(500).with_index do |rows, batch_index|
        objects = entity.batch_from_hash(rows.collect { |row| row.each { |key, col| col.try(:strip!) }.to_hash })
        if objects.present?
          objects.keep_if { |key, value| key != nil }
          objects.each_with_index { |object, index|
            object.valid? ? valid_objects << object : erroneous_objects.merge!({(500 * batch_index + index) => object.errors})
          }
        end
      end
      raise Exceptions::File::ErrorsInCsv.new(erroneous_objects) unless erroneous_objects.empty?
      valid_objects.each(&:save)
    end
  end

  def check_for_duplicates(csv_table, unique_attribute)
    return if unique_attribute.nil?
    values = csv_table[unique_attribute]
    duplicate_values = values.inject({}) { |count_hash, attr| count_hash[attr]=count_hash[attr].to_i+1; count_hash }.reject { |k, v| v==1 }.keys
    raise Exceptions::File::DuplicateEntityInCsv.new(duplicate_values) unless duplicate_values.empty?
  end
end
