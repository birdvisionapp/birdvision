class ClientManagerDashboard

  def initialize(admin_user, params)
    @current_ability = Ability.new(admin_user)
    @params = params
  end
  
  def redeemption_info
    Order.joins(:order_items).where("scheme_id in (?)", live_schemes)
  end
  
  def top_users_list
    sort_top_users(get_top_performers)
  end
  
  def sort_top_users(users)
    top_users = Array.new
    info = users.group('user_id').select('user_schemes.user_id, user_schemes.total_points').sum(:total_points)
    info = info.sort_by {|_key, value| value}.last(5)
    info.each do |u|
      users = User.find(u[0])
      top_users << {'full_name' => users.full_name, 'total_points' => u[1]} rescue {}
    end
    top_users.reverse!
  end
  
  def top_redemption_list
    sort_top_redemption(get_top_redemption_users)
  end
  
  def sort_top_redemption(users)
    # top_users = Array.new
    # users.each do |u|
    #   info = UserScheme.where('user_id = ?', u.id).pluck(:redeemed_points).first
    #   next if info.blank?
    #   top_users << {'full_name' => u.full_name, 'redeemed_points' => info} rescue {} 
    # end
    # redeemed = top_users.sort_by { |k| -k['redeemed_points'] }.first(5)

    top_users = Array.new
    info = users.group('user_id').select('scheme_transactions.user_id, scheme_transactions.points').sum(:points)
    info = info.sort_by {|_key, value| value}.last(5)
    info.each do |u|
      users = User.find(u[0])
      top_users << {'full_name' => users.full_name, 'redeemed_points' => u[1]} rescue {}
    end
    top_users.reverse!
  end
  
  def get_top_performers
    #User.joins(:client).where(clients: {id: clients})
    UserScheme.joins(user: :client).where(clients: {id: clients})
  end

  def get_top_redemption_users
    SchemeTransaction.joins(user: :client).where(clients: {id: clients}, scheme_transactions: {action: 'debit'})
  end
  
  def product_statistic
    @product_stats = Array.new
    categories = get_list_of_product_categories(clients)
    categories.each do |category|
      @search = UniqueItemCode
                        .joins(reward_item_point: {reward_item: :reward_product_catagory})
                        .where(reward_product_catagories: {id: category.id}).search(params[:q])
      total_codes = @search.result(:distinct => true).count
      @search = UniqueItemCode
                        .joins(reward_item_point: {reward_item: :reward_product_catagory})
                        .where(reward_product_catagories: {id: category.id}).where('used_at IS NOT NULL').search(params[:q])
      used_codes = @search.result(:distinct => true).count
      
      penetration = calculate_percentage_distribution(total_codes, used_codes) 
      @product_stats << {'category_name' => category.category_name, 'penetration' => penetration}
    end
    return @product_stats, @search
  end
  
  def used_codes
    @search = UniqueItemCode.used.includes(:reward_item_point => {:reward_item => [:client]}).where(clients: {id: clients}).search(params[:q])
    used_codes = @search.result(:distinct => true).count
    return used_codes, @search
  end
  
  def total_codes
    UniqueItemCode.unused.includes(:reward_item_point => {:reward_item => [:client]}).where(clients: {id: clients}).count
  end
  
  def community_size
    User.includes(:client => :msp, :telecom_circle => :regional_managers, :user_schemes => :scheme).where(:client_id => clients)
  end
  
  def community_heft
    #@community_heft = UniqueItemCode.joins(reward_item_point: {reward_item: :client}).where(clients: {id: clients}).where("used_at != ?", "nil").collect(&:reward_item_point_id)
    @community_heft = UniqueItemCode.used.joins(reward_item_point: {reward_item: :client}).where(clients: {id: clients}).group('reward_item_point_id').count
    @community_heft = sort_by_value_and_volume(@community_heft, @view_by)
  end
  
  def find_widget(name, admin_user)
    @wid_id= Widget.where('name = ?', name).pluck(:id).first
    @wid_manager = ClientManagersWidget.where('widget_id =? and client_manager_id = ?', @wid_id, admin_user.id).pluck(:id).first
  end
  
  def stockout_risklevel
    @stockout_risk = stockout_product.group('reward_item_point_id').count
    #@stockout_risk = @stockout_risk.used#.where('unique_item_codes.created_at > ?', 1.year.ago)
    #@uniqueitempoints = @stockout_risk.uniq.pluck(:reward_item_point_id)#group_by(&:reward_item_point_id)
    @stock_out_risk = unique_item_points(@stockout_risk, @date_diff)
  end

  def stockout_product
    #@stockout_risk = UniqueItemCode.joins(reward_item_point: {reward_item: :client}).joins(user: :telecom_circle).where(clients: {id: clients})
    @stockout_risk = UniqueItemCode.joins(reward_item_point: {:reward_item => [:client, :scheme]}).joins(user: :telecom_circle).where(clients: {id: clients}).where("used_at != ?", "nil")
  end  

  def participant_category_filter
    UserRole.where(:client_id => clients)
  end

  def region_filter
    RegionalManager.where(:client_id => clients).select_options
  end

  def sort_by_value_and_volume(value, view_by)
    points = []
    @volume = Array.new
    @metric = []
      value.each do |key, value|        
       a = RewardItemPoint.find(key)
        points << a.points * value
        if view_by == "2"
          if a.metric == 'l' || a.metric == 'g'
            @volume << 1 * value * a.pack_size.to_f
          end
          if a.metric == 'ml' || a.metric == 'mg'
            @volume << 0.001 * value * a.pack_size.to_f
          end
          if a.metric == 'kl' || a.metric == 'kg'
            @volume << 1000 * value * a.pack_size.to_f
          end
          if a.metric == 'units'
           @volume << 1 * value * a.pack_size.to_f
          end
          if a.metric == 'l' || a.metric == 'ml' || a.metric == 'kl'
            @metric << "Liter"
          end
          if a.metric == 'g' || a.metric == 'mg' || a.metric == 'kg'
            @metric << "Grams"
          end
          if a.metric == 'units'
            @metric << "Units"
          end
        end
      end
    if view_by == "2"
      @community_heft = @volume.sum
      return @community_heft, @metric
    else
      @community_heft = 1/client_point_rupee_conv * points.sum
      return @community_heft, @metric
    end
  end

  def unique_item_points(uniqueitempoints, date_diff)
    @stock_out_risk = Array.new
     uniqueitempoints.each do |f|
      @unique_items = RewardItemPoint.where(:id => f.first).first
      @unique_pack_size = @unique_items.pack_size
      @unique_metric = @unique_items.metric
      @unique_item = RewardItem.find(@unique_items.reward_item_id).name
      @unique_item_name = "#{@unique_item} - #{@unique_pack_size} #{@unique_metric.capitalize}"
      @value = f.last
      @unique_item_date = @unique_items.created_at
       if !date_diff.present?
         date_diff = (Date.today.beginning_of_day - @unique_item_date.beginning_of_day)/86400 rescue ""
       end
       @stock_out_risk << {'unique_item' => @unique_item_name, 'hit_count' => (@value/date_diff)}
     end
     @stock_out_risk = @stock_out_risk.sort_by { |k| -k["hit_count"] }.first(5)
  end

  def client_point_rupee_conv
    Client.where(:id => clients).first.points_to_rupee_ratio
  end

  def traction_user 
    User.joins(:client).where(clients: {id: clients})
  end
  
 def traction_count_user(users_traction, date_diff)
    @cumulative_count = Array.new
    @non_cumulative_count = Array.new
    cumulative_traction = users_traction.group("year(users.created_at)").count
    if !date_diff.present?
      elsif date_diff >= 32 && date_diff <= 365
        cumulative_traction = users_traction.group("year(users.created_at)").group("month(users.created_at)").count
      elsif date_diff <= 31
        cumulative_traction = users_traction.count(:order => 'DATE(users.created_at) DESC', :group => ["DATE(users.created_at)"])
      end
    cumulative_traction.each do |key, value|
      if @cumulative_count.last.blank?
        @cumulative_count << {'date' => key, 'user_count' => value }
      else
        @cumulative_count << {'date' => key, 'user_count' => value + @cumulative_count.last['user_count'] }
      end
      @non_cumulative_count << {'date' => key, 'user_count' => value }
    end
    return [@cumulative_count, @non_cumulative_count]
  end
  
  def community_traction
    @users_traction = traction_user
    @cumulative_traction = traction_count_user(@users_traction, @date_diff)
  end

  def total_reward_categories
    RewardProductCatagory.joins(:client).where(clients: {id: clients}).count
  end
  
  def reward_products
    RewardItem.joins(:client).where(clients: {id: clients})
  end
  
  def calculate_reward_item_penetration(item, search_params)
    @search = UniqueItemCode.used.joins(reward_item_point: :reward_item).where(reward_items: {id: item.id}).search(search_params)
    used = @search.result(:distinct => true).count
    total = UniqueItemCode.joins(reward_item_point: :reward_item).where(reward_items: {id: item.id}).count
    return {
      'id' => item.id,
      'name' => item.name,
      'penetration' => calculate_percentage_distribution(total, used)
    }, @search
  end
  
  def calculate_sku_level_penetration(sku, search_params)
    @search = UniqueItemCode.used.joins(:reward_item_point).where(reward_item_points: {id: sku.id}).search(search_params)
    used = @search.result(:distinct => true).count
    total = UniqueItemCode.joins(:reward_item_point).where(reward_item_points: {id: sku.id}).count
    return {
      'id' => sku.id,
      'pack_size' => sku.pack_size,
      'metric' => sku.metric,
      'penetration' => calculate_percentage_distribution(total, used)
    }, @search
  end
  
  private
  
  def get_list_of_product_categories(client_id)
    RewardProductCatagory.find(:all, 'client_id =?', client_id)
  end
  
  def calculate_percentage_distribution(total_codes, used_codes)
    if total_codes > 0  
      return ((used_codes * 100) / total_codes)
    else
      return 0
    end
  end
  
  def clients
    @clients ||= Client.accessible_by(current_ability).live_client.pluck(:id)
  end
  
  def schemes
    @schemes ||= Scheme.accessible_by(current_ability)
  end

  def live_schemes
    @live_schemes ||= schemes.accessible_by(current_ability).where(client_id: clients)
  end

  def current_ability
    @current_ability
  end

  def params
    @params
  end
  
end