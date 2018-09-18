module Admin::Reports::PointsSummaryReport

  include ViewsHelper

  include ActionView::Helpers::UrlHelper

  include ActionView::Helpers::NumberHelper
  
  include SchemeTransactionsHelper

  def to_csv options = {}
    CSV.generate do |csv|
      csv << csv_header(options)
      find_each(:batch_size => 6000) do |transaction|
        csv << csv_row(transaction, options)
      end
    end
  end

  def csv_header(options)
    header = ["Date", "Scheme", "Participant Full Name", "Participant Username", "Description", "Credit", "Debit", "Balance"]
    if options[:role] == 'super_admin'
      header.unshift("Client")
      header.unshift("MSP") if options[:is_super_admin]
    end
    header
  end

  def csv_row(transaction, options)
    summary = points_summary_for(transaction, true, false)
    row = [transaction.created_at.strftime("%d-%b-%Y"),
      transaction.scheme.name,
      transaction.user.full_name,
      transaction.user.username,
      summary[:description],
      summary[:credit],
      summary[:debit],
      summary[:balance]
    ]
    if options[:role] == 'super_admin'
      row.unshift(transaction.client.client_name)
      row.unshift(transaction.client.msp_name) if options[:is_super_admin]
    end
    row
  end

end
