class AdminDashboard

  attr_reader :redeemable_schemes

  def initialize(admin_user)
    @current_ability = Ability.new(admin_user)
  end

  def redeemable_schemes_budget
    SchemeBudget.for_schemes(redeemable_schemes.where(:single_redemption => false)).sum(&:total_rupees_uploaded)
  end

  def all_schemes_budget
    SchemeBudget.for_schemes(live_schemes.includes(:client).where(:single_redemption => false)).sum(&:total_rupees_uploaded)
  end

  def all_redeemable_schemes
    redeemable_schemes
  end

  def top_redeemable_schemes
    redeemable_schemes.limit(4)
  end

  def redemption_per_scheme
    Order.joins(:order_items).where("scheme_id in (?)", redeemable_schemes).merge(OrderItem.valid_orders).sum(:price_in_rupees).to_i
  end

  def all_schemes_redemption
    Order.joins(:order_items).where("scheme_id in (?)", live_schemes).merge(OrderItem.valid_orders).sum(:price_in_rupees).to_i
  end

  def scheme_stats
    {:redeemable => redeemable_schemes.select(:id).count,
     :past => schemes.expired.select(:id).count,
     :upcoming => schemes.pre_redemption.select(:id).count}
  end

  def order_stats
    Hash[[:new, :sent_to_supplier, :delivery_in_progress, :delivered, :incorrect, :refunded].collect { |status| [status, order_items_count[status.to_s]|| 0] }]
  end

  def participant_stats
    users.group(:status).count
  end

  private

  def clients
    @clients ||= Client.accessible_by(current_ability).live_client.pluck(:id)
  end
  
  def schemes
    @schemes ||= Scheme.accessible_by(current_ability)
  end

  def order_items_count
    @order_items_count ||= OrderItem.accessible_by(current_ability).group(:status).count
  end

  def users
    @users ||= User.accessible_by(current_ability)
  end

  def current_ability
    @current_ability
  end

  def redeemable_schemes
    @redeemable_schemes ||= schemes.redeemable
  end

  def live_schemes
    @live_schemes ||= schemes.accessible_by(current_ability).where(client_id: clients)
  end
end
