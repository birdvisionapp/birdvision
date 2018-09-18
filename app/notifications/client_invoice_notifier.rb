class ClientInvoiceNotifier

  def self.notify(client_invoice)
    recipients = client_invoice.client.client_managers.select([:email, :mobile_number])
    ClientInvoiceMailer.delay.generated(client_invoice, App::Config.settings[:accounts_email], true) if App::Config.settings[:accounts_email].present?
    return nil unless recipients.present?
    emails, mobile_numbers = recipients.map(&:email).uniq, recipients.map(&:mobile_number).uniq
    emails.each {|email| ClientInvoiceMailer.delay.generated(client_invoice, email) } if emails.present?
    mobile_numbers.each {|mobile_number| SmsMessage.new(:client_invoice_generated, :to => mobile_number, :label => client_invoice.invoice_label, :changes => "#{client_invoice.description}, #{client_invoice.invoice_label}: #{client_invoice.invoice_number}, Date: #{client_invoice.invoice_date}, Amount: #{client_invoice.amount}", :client => client_invoice.client.client_name, :app_title => APP_TITLE).delay.deliver } if mobile_numbers.present?
  end

end