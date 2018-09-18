class ClientInvoiceMailer < ActionMailer::Base
  helper :mail_url, :views
  default :from => "no-reply@birdvision.in"
  include SendGrid

  def generated client_invoice, recipient, accounts_dept = false
    sendgrid_category 'Client Invoice Generated'
    sendgrid_unique_args :invoice_number => client_invoice.invoice_number
    invoice_pdf = ClientInvoicePdf.new(client_invoice, view_context)
    @client_invoice = client_invoice
    @pay_date = view_context.humanize_date(Date.today.at_beginning_of_month.next_month+2.days)
    attachments[client_invoice.filename] = {
      mime_type: 'application/pdf',
      content: invoice_pdf.render
    }
    @accounts_dept = accounts_dept
    mail :to => recipient, :subject => "#{(@accounts_dept) ? client_invoice.client.client_name : APP_TITLE} - #{client_invoice.invoice_label} has been generated for #{client_invoice.invoice_type.titleize} Number: #{client_invoice.invoice_number} Date: #{view_context.humanize_date(client_invoice.invoice_date)}", :template_path => "mailers/client_invoice"
  end
end
