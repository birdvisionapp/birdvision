class Admin::OrderItemsController < Admin::AdminController
  load_and_authorize_resource

  inherit_resources
  actions :index

  def index
    default_sort = 'created_at desc'
    respond_to do |format|
      format.html {
        @search = OrderItem.accessible_by(current_ability).includes(:scheme, :supplier, :client_item => {:item => [:preferred_supplier, :item_suppliers]},
          :order => {:user => {:client => {:client_resellers => :reseller}}}).accessible_by(current_ability).search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @orders = @search.result.page(params[:page])
      }
      format.csv {
        process_csv_report("Orders Report till #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "OrderItem.includes(:scheme, :supplier, :client_item => {:item => [:preferred_supplier, :item_suppliers]}, :order => {:user => {:client => {:client_resellers => :reseller}}}).accessible_by(current_ability).search(#{params[:q]})", default_sort: default_sort)
      }
    end
  end

  def edit
    @order_item = OrderItem.find(params[:id])
    @order = Order.find(@order_item.order_id)
  end

  def update
    @order_item = OrderItem.where(order_id: params[:id]).first
    @order = Order.find(@order_item.order_id)
    if @order.update_attributes(params[:order])
      flash[:notice] = "Address has been updateds"
      redirect_to admin_order_items_path
    else
      flash[:alert] = "Error while updating the address"
      redirect_to edit_admin_order_item_path, :id => @order.id
    end
  end

  def change_status
    order_item = OrderItem.accessible_by(current_ability).find_by_id(params[:order_item_id])
    if valid_action?(params)
      order_item.send(params[:perform_action])
      flash[:notice] = App::Config.messages[:order_item][:valid_change_in_status] % [order_item.client_item.title, order_item.order.order_id]
    else
      flash[:notice] = App::Config.errors[:order_item][:invalid_change_in_status]
    end
    flash.keep
    redirect_to admin_order_items_path(:q => params[:q])
  end

  def approve_order
    @order_item = OrderItem.find_by_id(params[:order_item_id])
    unless params[:cancel_order] == "true"
      @order_item.order_approved = true
      if @order_item.save!
        flash[:notice] = App::Config.errors[:order_item][:order_approved]
      else
        flash[:notice] = App::Config.errors[:order_item][:order_approved_fail]
      end
      flash.keep
    else
      @order_item.send("incorrect")
      @order_item.send("refund")
    end
    redirect_to admin_order_items_path(:q => params[:q])
  end

  def edit_tracking_info
    @order_item = OrderItem.accessible_by(current_ability).find(params[:order_item_id])
  end

  def update_tracking_info
    @order_item = OrderItem.accessible_by(current_ability).find(params[:order_item_id])
    @order_item.update_attributes(params[:order_item])

    flash[:notice] = App::Config.messages[:order_item][:tracking_info_update] % [@order_item.client_item.title, @order_item.order.order_id]
    flash.keep
    redirect_to admin_order_items_path(:q => params[:q])
  end

  def valid_action? params
    OrderItem.accessible_by(current_ability).valid_status_event? params[:perform_action]
  end

end


