class SchemeTransactionsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @search = current_user.scheme_transactions.includes(:scheme).select('scheme_transactions.id, scheme_transactions.scheme_id, scheme_transactions.points, scheme_transactions.remaining_points, scheme_transactions.action, scheme_transactions.transaction_type, scheme_transactions.transaction_id, scheme_transactions.user_id, scheme_transactions.created_at').search(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @point_transactions = @search.result.page(params[:page])
    @hide_search = true
  end

end