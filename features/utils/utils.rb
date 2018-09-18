module Utils

  def report_javascript_errors()
    if page.driver.error_messages.present?
      errors = page.driver.error_messages
      puts '-------------------------------------------------------------'
      puts "Found #{errors.length} javascript error(s)"
      puts '-------------------------------------------------------------'
      errors.each do |error|
        puts errors
      end
      raise "Javascript error(s) detected, see above"
    end
  end

  def verify(bool, message)
    @error_messages << message unless bool
  end

end

World(Utils)