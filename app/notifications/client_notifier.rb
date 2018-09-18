class ClientNotifier

  def self.notify(client)
    recipients = client.client_managers.select([:email, :mobile_number])
    balance_days = (client.closing_balance/client.average_points).round.to_i if client.average_points > 0
    if client.closing_balance && (balance_days && balance_days <= 7) && recipients.present?
      emails, mobile_numbers = recipients.map(&:email).uniq, recipients.map(&:mobile_number).uniq
      options = {
        balance_date: Time.now.strftime("%I:%M%P on %B %d, %Y"),
        balance_points: client.closing_balance,
        avg_points: client.average_points,
        balance_days: (balance_days > 0) ? balance_days : 0
      }
      emails.each {|email| ClientMailer.delay.balance_reminder(client, email, options) } if emails.present?
      mobile_numbers.each {|mobile_number| SmsMessage.new(:client_reminder_low_balance, options.merge!(client: client.client_name, to: mobile_number, app_title: APP_TITLE)).delay.deliver } if mobile_numbers.present?
    end
  end

end