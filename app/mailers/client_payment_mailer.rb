class ClientPaymentMailer < ActionMailer::Base
  helper :mail_url, :views
  default :from => "no-reply@birdvision.in"
  include SendGrid

  def info_updated client_payment, recipient
    sendgrid_category 'Client Payment Information Updated'
    sendgrid_unique_args :payment_id => client_payment.id, :invoice_number => client_payment.client_invoice.invoice_number
    @client_payment = client_payment
    @subject_slug = (@client_payment.credited_at.present?) ? 'Payment is confirmed' : 'Payment Details has been updated'
    mail :to => recipient, :subject => "#{APP_TITLE} - #{@subject_slug} for #{@client_payment.client_invoice.invoice_label}: #{@client_payment.client_invoice.invoice_number} Date: #{view_context.humanize_date(@client_payment.client_invoice.invoice_date)}", :template_path => "mailers/client_payment"
  end
end
