class ClientPaymentNotifier

  def self.notify(client_payment)
    recipients = client_payment.client_invoice.client.client_managers.select([:email, :mobile_number])
    return nil unless recipients.present?
    emails, mobile_numbers = recipients.map(&:email).uniq, recipients.map(&:mobile_number).uniq
    emails.each {|email| ClientPaymentMailer.delay.info_updated(client_payment, email) } if emails.present?
    if mobile_numbers.present?
      mobile_numbers.each {|mobile_number|
        parameters = {:to => mobile_number, :invoice => client_payment.client_invoice.invoice_number, :client => client_payment.client_invoice.client.client_name, :app_title => APP_TITLE}
        if client_payment.is_paid?
          SmsMessage.new(:client_payment_confirm_points, parameters.merge(points: client_payment.client_invoice.points)).delay.deliver if client_payment.points_credited?
          SmsMessage.new(:client_payment_confirm_monthly_retainer, parameters.merge(exp_date: client_payment.client_invoice.client.expiry_date.strftime('%d-%m-%Y'))).delay.deliver if client_payment.client_invoice.monthly_retainer?
        else
          SmsMessage.new(:client_payment_info_updated, parameters).delay.deliver
        end  
      }
    end
  end

end