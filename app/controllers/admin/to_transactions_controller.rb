class Admin::ToTransactionsController < ApplicationController
  
  layout "admin"
  before_filter :authenticate_admin_user!
  load_and_authorize_resource
  inherit_resources

  def index
    default_sort = 'created_at desc'
    @basis = TargetedOfferType.all
    respond_to do |format|
      format.html {
        @search = ToTransaction.accessible_by(current_ability).search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @to_orders = @search.result.page(params[:page])
      }
      format.csv {
        process_csv_report("Targeted Offer Transactions Report till #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "ToTransaction.accessible_by(current_ability).search(#{params[:q]})", default_sort: default_sort)
      }
    end
  end

  # def index
  #   if current_admin_user.role == AdminUser::Roles::SUPER_ADMIN
  #     @transactions = ToTransaction.all
  #   elsif current_admin_user.role == AdminUser::Roles::CLIENT_MANAGER
  #     @transactions = ToTransaction.joins(:targeted_offer_config).where(targeted_offer_configs: {client_id: clients})
  #   end
  # end

  def edit
    @to_order_item = ToTransaction.find(params[:id])
  end

  def update
    @to_order_item = ToTransaction.find(params[:id])
    if @to_order_item.update_attributes(params[:to_transaction])
      flash[:notice] = "Address has been updateds"
      redirect_to admin_to_transactions_path
    else
      flash[:alert] = "Error while updating the address"
      redirect_to edit_admin_to_transaction_path, :id => @to_order_item.id
    end
  end

  def to_change_status
    to_order_item = ToTransaction.accessible_by(current_ability).find_by_id(params[:to_transaction_id])
    if valid_action?(params)
      to_order_item.send(params[:perform_action])
      to_gift_name = gift_name(to_order_item)
      flash[:notice] = App::Config.messages[:to_order_item][:valid_change_in_status] % [to_gift_name, "RID#{to_order_item.id}"]
    else
      flash[:notice] = App::Config.errors[:to_order_item][:invalid_change_in_status]
    end
    flash.keep
    redirect_to admin_to_transactions_path(:q => params[:q])
  end

  def to_edit_tracking_info
    @to_order_item = ToTransaction.accessible_by(current_ability).find(params[:to_transaction_id])
  end

  def to_update_tracking_info
    @to_order_item = ToTransaction.accessible_by(current_ability).find(params[:to_transaction_id])
    @to_order_item.update_attributes(params[:to_transaction])
    to_gift_name = gift_name(@to_order_item)

    flash[:notice] = App::Config.messages[:to_order_item][:tracking_info_update] % [to_gift_name, "RID#{@to_order_item.id}"]
    flash.keep
    redirect_to admin_to_transactions_path(:q => params[:q])
  end
  
  private
  
  def clients
    @clients ||= Client.accessible_by(current_ability).live_client.pluck(:id)
  end

  def valid_action? params
    ToTransaction.accessible_by(current_ability).valid_status_event? params[:perform_action]
  end
  
  def gift_name transaction
    targeted_offer_config = transaction.targeted_offer_config.id
    incentive = Incentive.where(:targeted_offer_configs_id => targeted_offer_config).first.incentive_detail
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

end
