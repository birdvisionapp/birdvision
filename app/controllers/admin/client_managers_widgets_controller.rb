class Admin::ClientManagersWidgetsController < ApplicationController

  layout "admin"
  
  before_filter :authenticate_admin_user!
    
  def index
    @client_manager_dashboard = ClientManagerDashboard.new(current_admin_user, params)
    @widgets = ClientManagersWidget.where('client_manager_id = ?', current_admin_user.id)
    @dashboard = AdminDashboard.new(current_admin_user)
      @widgets_name = Array.new
      @widgets.each do |wid|
        widget = Widget.find(wid.widget_id)
        @widgets_name << widget.name
      end
      @widgets_name
  end

  def new
    @client_manager_widget = ClientManagersWidget.new
  end
  
  def create
    @client_manager_widget = ClientManagersWidget.new
    @widget_id = params[:widget_id]
    @client_manager_widget.widget_id = @widget_id
    @client_manager_widget.client_manager_id = current_admin_user.id
    @check_widget = ClientManagersWidget.where('client_manager_id = ? and widget_id = ?', current_admin_user.id, @widget_id)
    @total_check_count = ClientManagersWidget.where('client_manager_id = ?', current_admin_user.id).count

    if !@check_widget.empty?
      flash[:alert] = "Widget is already in your list"
      redirect_to admin_widgets_path
    elsif @total_check_count >= 6
      flash[:alert] = "You have reached to maximum Widget limit."
      redirect_to admin_widgets_path
    else
      if @client_manager_widget.save!
        flash[:notice] = "Widget successfully added to your list"
        redirect_to admin_widgets_path
      else
        flash[:alert] = "Error while adding widgets."
        render admin_widgets_path
      end      
    end
  end
  
 def destroy
    @client_manager_widget = ClientManagersWidget.find(params[:id])
    @client_manager_widget.destroy
    respond_to do |format|
      flash[:notice] = "Widget was deleted successfully"
      format.html { redirect_to admin_client_managers_widgets_url }
      format.js { render :nothing => true }
    end
  end
  
  def product_penetration
    @dashboard = ClientManagerDashboard.new(current_admin_user, params)
    @product_stats = @dashboard.product_statistic
    @product_stats = @product_stats.first
  end
  
  def redemption
    default_sort = 'created_at desc'
    dashboard = ClientManagerDashboard.new(current_admin_user, params)
    @telecom_regions = dashboard.region_filter
    redeemabed_info = dashboard.redeemption_info
    respond_to do |format|
      format.html {
        @search = redeemabed_info.merge(OrderItem.valid_orders).search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        @orders = @search.result(:distinct => true)#.sum(:price_in_rupees).to_i
        @order_id = @orders.collect(&:id)
        @order_items = OrderItem.where(:order_id => @order_id)
        @price_in_rupees = @order_items.collect(&:price_in_rupees)
        @orders = @price_in_rupees.sum.to_i
      }
    end
  end
  
  def top_users
    default_sort = 'users.updated_at desc'
    @dashboard = ClientManagerDashboard.new(current_admin_user, params)
    @telecom_regions = @dashboard.region_filter
    @users_list = @dashboard.get_top_performers
    @search = @users_list.search(params[:q])
    @search.sorts = default_sort if @search.sorts.empty?
    @users = @search.result(:distinct => true)
    @top_users = @dashboard.sort_top_users(@users)
  end
  
  
  def loyalty_index
    
  end
  
  def community_size
    @dashboard = ClientManagerDashboard.new(current_admin_user, params)
    @current_admin = @dashboard.participant_category_filter
    @telecom_regions = @dashboard.region_filter
    model = @dashboard.community_size
    model = model.region_scope if params[:q] && params[:q][:telecom_circle_regional_managers_id_eq].present?
    @search = model.search(params[:q])
    @users_count = @search.result.count
  end

 def community_heft
  @dashboard = ClientManagerDashboard.new(current_admin_user, params)
  @telecom_regions = @dashboard.region_filter

  @date = Date.parse(params[:q][:used_at_gteq]).beginning_of_day rescue ""
  @start_date = Date.parse(params[:q][:used_at_date_gteq]).beginning_of_day rescue ""
  @end_date = Date.parse(params[:q][:used_at_date_lteq]).end_of_day rescue ""
  @telecome_circle = params[:q][:user_telecom_circle_regional_managers_id_eq] rescue ""
  @view_by = params[:q][:user_telecom_circle_id_eq] rescue ""

    @search = UniqueItemCode.search(params[:q])
     if @telecome_circle.present?
        #@community_heft = UniqueItemCode.joins(reward_item_point: {reward_item: :client}).joins(user: :telecom_circle).where(clients: {id: clients}, telecom_circles: {id: @telecome_circle}).where("used_at != ?", "nil")
        @community_heft = UniqueItemCode.joins(reward_item_point: {reward_item: :client}).joins(user: {telecom_circle: :regional_managers}).where(clients: {id: clients}, regional_managers: {id: @telecome_circle}).where("used_at != ?", "nil")
     else
        @community_heft = UniqueItemCode.joins(reward_item_point: {reward_item: :client}).where(clients: {id: clients}).where("used_at != ?", "nil")
     end
     @community_heft
     if !@date.present? && @start_date.blank? && @end_date.blank?
        @community_heft = @community_heft.group('reward_item_point_id').count
     end
     if @date.present? && @start_date.blank? && @end_date.blank?
        @community_heft = @community_heft.where('unique_item_codes.used_at >= ?', @date).group('reward_item_point_id').count
     end  
     if !@date.present? && !@start_date.blank? && !@end_date.blank?
        @community_heft = @community_heft.where(:used_at => @start_date..@end_date).group('reward_item_point_id').count
     end
     if !@date.present? && @start_date.blank? && !@end_date.blank?
        @community_heft = @community_heft.where('unique_item_codes.used_at <= ?', @end_date).group('reward_item_point_id').count
     end 
        @community_heft_total = @dashboard.sort_by_value_and_volume(@community_heft, @view_by)
 end

 def stockout_risklevel
  @dashboard = ClientManagerDashboard.new(current_admin_user, params)
  @telecom_regions = @dashboard.region_filter

  @start_date_single = Date.parse(params[:q][:used_at_gteq]).beginning_of_day rescue ""
  @start_date = Date.parse(params[:q][:used_at_date_gteq]).beginning_of_day rescue ""
  @end_date = Date.parse(params[:q][:used_at_date_lteq]).end_of_day rescue ""
  if @end_date.present?
    @date_diff = (@end_date - @start_date)/86400 rescue ""
  elsif @start_date_single.present?
    @date_diff = (Date.today.beginning_of_day - @start_date_single)/86400 + 1 rescue ""
  end
  @stockout_product = @dashboard.stockout_product
  @search = @stockout_product.search(params[:q])
  @result = @search.result(:distinct => true).group('reward_item_point_id').count
  #@uniqueitempoints = @result.group_by(&:reward_item_point_id)
  @stock_out_risk = @dashboard.unique_item_points(@result, @date_diff)
 end

 def top_redemptions
   default_sort = 'users.updated_at desc'
   @dashboard = ClientManagerDashboard.new(current_admin_user, params)
   @telecom_regions = @dashboard.region_filter
   @users_list = @dashboard.get_top_redemption_users
   @search = @users_list.search(params[:q])
   @search.sorts = default_sort if @search.sorts.empty?
   @users = @search.result(:distinct => true)
   @top_redemptions = @dashboard.sort_top_redemption(@users)
 end

 def penetration
    @dashboard = ClientManagerDashboard.new(current_admin_user, params)
    @total_codes = @dashboard.total_codes
    @used_codes = @dashboard.used_codes.first
 end

 def sku_level
   @sku_info = Array.new
   dashboard = ClientManagerDashboard.new(current_admin_user, params)
   @reward_item_name = RewardItem.find(params[:id]).name
   reward_item_sku = RewardItemPoint.joins(:reward_item).where(reward_items: {id: params[:id]})
   search_params = params[:q]
   @search = UniqueItemCode.search(params[:q])
   reward_item_sku.each do |sku|
    @tes = dashboard.calculate_sku_level_penetration(sku, search_params)
    @sku_info << @tes.first
   end
    @sku_info.sort_by { |k| -k['penetration'] }
 end

 def reward_item_level
   dashboard = ClientManagerDashboard.new(current_admin_user, params)
   products = dashboard.reward_products
   search_params = params[:q]
   penetrations, search = penetrations(products, search_params)
   @search = UniqueItemCode.search(params[:q])
   @top_penetrations, @worst_penetrations = refactor_penetrations(penetrations)
 end

 def category_reward_items
   products = RewardItem.joins(reward_product_catagory: :client).where(clients: {id: clients})
   search_params = params[:q]
   @search = UniqueItemCode.search(params[:q])
   penetrations, search = penetrations(products, search_params)
   @top_penetrations, @worst_penetrations = refactor_penetrations(penetrations)
 end

 def overall_product_penetration
    penetration = Array.new
    dashboard = ClientManagerDashboard.new(current_admin_user, params)
    @search = RewardItem.joins(:client).where(clients: {id: clients}).search(params[:q])
    products = @search.result(:distinct => true)
    search_params = params[:q]
    products.each do |item|
      trations, search = dashboard.calculate_reward_item_penetration(item, search_params)
      penetration << trations
    end
    @penetrations = penetration.sort_by { |k| -k['penetration'] }
    @total_penetrations = Kaminari.paginate_array(@penetrations).page(params[:page]).per(10)
 end

  def traction
    @dashboard = ClientManagerDashboard.new(current_admin_user, params)
    @telecom_regions = @dashboard.region_filter
    @start_date_single = Date.parse(params[:q][:created_at_gteq]).beginning_of_day rescue ""
    @start_date = Date.parse(params[:q][:created_at_date_gteq]).beginning_of_day rescue ""
    @end_date = Date.parse(params[:q][:created_at_date_lteq]).end_of_day rescue ""
    if @start_date.present? && @end_date.present?
      @date_diff = (@end_date - @start_date)/86400 rescue ""
    end
    if @start_date.present? && !@end_date.present?
      @date_diff = (Date.today.beginning_of_day - @start_date)/86400 + 1 rescue ""
    end
    if @start_date_single.present?
      @date_diff = (Date.today.beginning_of_day - @start_date_single)/86400 + 1 rescue ""
    end
    @users_traction = @dashboard.traction_user
    @search = @users_traction.search(params[:q])
    @users_traction = @search.result(:distinct => true)
    @cumulative_traction = @dashboard.traction_count_user(@users_traction, @date_diff)
    @cumulative_tractions = @cumulative_traction.first.to_json
    @non_cumulative_traction = @cumulative_traction.last.to_json
  end

  private
  
  def clients
    @clients ||= Client.accessible_by(current_ability).live_client.pluck(:id)
  end
  
  def schemes
    @schemes ||= Scheme.accessible_by(current_ability)
  end

  def live_schemes
    @live_schemes ||= schemes.accessible_by(current_ability).where(client_id: clients)
  end

  def penetrations(products, search_params)
    penetration = Array.new
    @dashboard = ClientManagerDashboard.new(current_admin_user, params)
    products.each do |item|
      trations, search = @dashboard.calculate_reward_item_penetration(item, search_params)
      penetration << trations
    end
    return penetration, search_params
  end
  
  def refactor_penetrations(penetrations)
   if penetrations.count >= 0
    if penetrations.count < 8 && penetrations.count > 0
      divide_penetrations = penetrations.each_slice( (penetrations.size/2.0).round ).to_a
      @top_penetrations = top_penetrations(divide_penetrations[0])
      @worst_penetrations = worst_penetrations(divide_penetrations[1])
    else
      @top_penetrations = top_penetrations(penetrations)
      @worst_penetrations = worst_penetrations(penetrations)
    end
    return @top_penetrations, @worst_penetrations
   else
    return 0
  end
  end
  
  def top_penetrations(penetrations)
    penetrations.sort_by { |k| -k['penetration'] }.first(5)
  end
  
  def worst_penetrations(penetrations)
    penetrations.sort_by { |k| k['penetration'] }.first(5)
  end
  
end
