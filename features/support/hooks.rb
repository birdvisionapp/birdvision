Before('@javascript') do |scenario|
  @error_messages=[]
end

After ('@javascript') do |scenario|
  if(page.driver.to_s.match("Webkit"))
    report_javascript_errors()
  end

  if(!@error_messages.empty?)
    @error_messages.each do |message|
      p message
    end
    fail("Scenario failed! Please read the above messages")
  end
end
