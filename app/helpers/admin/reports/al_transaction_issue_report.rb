module Admin::Reports::AlTransactionIssueReport
  include ViewsHelper
  include Admin::UsersHelper

  def to_csv options = {}
    CSV.generate do |csv|
      csv << csv_header(options)
      find_each(:batch_size => 6000) do |user|
        csv << csv_row(user, options)
      end
    end
  end

  def csv_header(options)
    header = ["Created At", "Sap Code", "Purchase Date", "Sales Office Code", "Sales Group Code", "Dealer Hierarchy", "Part Number", "Quantity", "Error"]
  end

  def csv_row(user, options)
    row = [user.created_at.strftime("%d-%b-%Y"),
           user.sap_code,
           user.purchase_date,
           user.sales_office_code,
           user.sales_group_code,
           user.dealer_hierarchy,
           user.part_number,
           user.quantity,
           user.error]
  end

end

