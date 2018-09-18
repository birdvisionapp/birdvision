class ClientBudget

  attr_accessor :clients, :date

  def initialize(clients, date = '')
    @clients = clients
    @date = date
  end

  def total_points_uploaded
    user_schemes = UserScheme.select(:total_points).where(build_condition)
    user_schemes.present? ? user_schemes.sum(:total_points).to_i : 0
  end

  def total_points_redeemed
    order_items = OrderItem.select(:points_claimed).where(build_condition).valid_orders
    order_items.present? ? order_items.sum(:points_claimed).to_i : 0
  end

  def total_points_credited
    client_points = ClientPointCredit.select(:points).where(build_client_condition)
    client_points.present? ? client_points.sum(:points).to_i : 0
  end

  def balance_paid_points
   (total_points_credited - total_points_redeemed)
  end

  private

  def build_condition
    block_cond = {scheme_id: schemes.pluck(:id)}
    condition = "scheme_id IN(:scheme_id)"
    if @date.present?
      condition << " AND DATE(created_at)=:created_at"
      block_cond.merge!(created_at: @date)
    end
    [condition, block_cond]
  end

  def build_client_condition
    block_cond = {client_id: @clients}
    condition = "client_id IN(:client_id)"
    if @date.present?
      condition << " AND DATE(created_at)=:created_at"
      block_cond.merge!(created_at: @date)
    end
    [condition, block_cond]
  end

  def schemes
    @schemes ||= Scheme.where(:client_id => @clients)
  end

end