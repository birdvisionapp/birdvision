class AlTransactionIssue < ActiveRecord::Base
  extend CSVImportable
  
  extend Admin::Reports::AlTransactionIssueReport
   
   attr_accessible :user_id, :sap_code, :purchase_date, :sales_office_code, :sales_group_code, :dealer_hierarchy, :part_number, :quantity, :part_points, :total_points, :error

end
