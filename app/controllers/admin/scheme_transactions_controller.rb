class Admin::SchemeTransactionsController < Admin::AdminController

  load_and_authorize_resource

  def index
    default_sort = 'id desc'
    respond_to do |format|
      format.html {
        @search = SchemeTransaction.includes(:user, :scheme, :client => :msp).accessible_by(current_ability).select('scheme_transactions.id, scheme_transactions.client_id, scheme_transactions.scheme_id, scheme_transactions.points, scheme_transactions.remaining_points, scheme_transactions.action, scheme_transactions.transaction_type, scheme_transactions.transaction_id, scheme_transactions.user_id, scheme_transactions.created_at').search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @scheme_transactions = @search.result.page(params[:page])
        if params[:q]
          @user_params = params[:q][:user_id_eq]
        end
        #@scheme_budget = SchemeBudget.for_schemes(@search.result.map(&:scheme).uniq)
      }
      format.csv { 
        process_csv_report("Points Statement Report #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "SchemeTransaction.includes(:user, :scheme, :client => :msp).accessible_by(current_ability).select('scheme_transactions.id, scheme_transactions.client_id, scheme_transactions.scheme_id, scheme_transactions.points, scheme_transactions.remaining_points, scheme_transactions.action, scheme_transactions.transaction_type, scheme_transactions.transaction_id, scheme_transactions.user_id, scheme_transactions.created_at').search(#{params[:q]})", default_sort: default_sort)
      }
    end
  end

end


