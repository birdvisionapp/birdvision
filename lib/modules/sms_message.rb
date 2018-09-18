class SmsMessage

  def initialize(template, options={})
    @template = template
    @options = options
  end

  def deliver
    return nil if @options[:to].start_with?('0')
    Rails.logger.info "[SmsMessage::deliver] Sending #{@template.to_s.humanize} sms: from #{from} with #{@options}"
    if from.present?
      response = Exotel::Sms.new.send(:from => from, :to => @options[:to], :body => body)
      Rails.logger.info "[SmsMessage::deliver] Sent #{@template.to_s.humanize} sms: sid #{response.sid}"
      return response.sid
    end
  end

  private
  def body
    I18n.interpolate(App::Config.sms_templates[@template], @options)
  end

  def from
    @from ||= ENV["SMS_SENDER"]
  end
end