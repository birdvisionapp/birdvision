class Admin::ClientPointReportsController < Admin::AdminController

  load_and_authorize_resource

  def index
    default_sort = 'trans_date desc'
    select_fields = 'client_point_reports.id, client_point_reports.client_id, client_point_reports.trans_date, client_point_reports.credit, client_point_reports.debit, client_point_reports.balance'
    respond_to do |format|
      format.html {
        @search = ClientPointReport.includes(init_includes).accessible_by(current_ability).select(select_fields).search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @client_point_reports = @search.result.page(params[:page])
      }
      format.csv { 
        process_csv_report("Points Statement Report #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "ClientPointReport.includes(:client => :msp).accessible_by(current_ability).select('#{select_fields}').search(#{params[:q]})", default_sort: default_sort)
      }
    end
  end

end


