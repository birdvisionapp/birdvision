class Admin::Sales::ResellerDashboardController < Admin::AdminController
  def index
    authorize! :view, :reseller_dashboard
    @search = Client.accessible_by(current_ability).for_reseller(current_admin_user.reseller).search(params[:q])
    @clients = @search.result.order("created_at desc").page(params[:page])
  end

  def orders
    authorize! :view, :reseller_dashboard
    default_sort = 'created_at desc'
    client_reseller = ClientReseller.includes(:client).for_client(params[:client_id], current_admin_user.reseller.id).last
    @client = client_reseller.client
    respond_to do |format|
      format.html {
        @search = client_reseller.order_items_in_payout_range.search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @order_items = @search.result.page(params[:page])
        @total_sale_price = client_reseller.sales
        @payout = client_reseller.payout
      }
      format.csv {
        process_csv_report("Orders report for #{@client.client_name} report on #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "ClientReseller.includes(:client).for_client(#{params[:client_id]}, #{current_admin_user.reseller.id}).last.order_items_in_payout_range.search(#{params[:q]})", dyn_method: 'orders_report_of', default_sort: default_sort)
      }
    end
  end

  def participants
    authorize! :view, :reseller_dashboard
    @client = Client.accessible_by(current_ability).find(params[:client_id])
    respond_to do |format|
      format.html {
        @search = UserScheme.joins(:scheme).where("schemes.client_id = ?", @client.id).search(params[:q])
        @user_schemes = @search.result.page(params[:page])
      }
      format.csv {
        process_csv_report("Participants report for #{@client.client_name} report on #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "UserScheme.joins(:scheme).where('schemes.client_id = ?', #{@client.id}).search(#{params[:q]})", dyn_method: 'participants_report_of')
      }
    end
  end
end