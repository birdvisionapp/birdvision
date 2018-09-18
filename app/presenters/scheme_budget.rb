class SchemeBudget
  include ActionView::Helpers::NumberHelper
  include ViewsHelper

  attr_accessor :scheme

  def initialize(scheme, scheme_points)
    @scheme = scheme
    @scheme_points = scheme_points
  end

  def exceeded?
    total_points_uploaded > total_budget_in_points
  end

  def total_budget_in_points
    (@scheme.total_budget_in_rupees || 0) * rupee_ratio
  end

  def total_points_uploaded
    @scheme_points[@scheme] || 0
  end

  def total_rupees_redeemed
    order_items.sum(:price_in_rupees).to_i
  end

  def total_points_redeemed
    order_items.sum(:points_claimed).to_i
  end

  def total_rupees_uploaded
    total_points_uploaded / rupee_ratio
  end

  def self.for_schemes(schemes)
    total_points_per_scheme = UserScheme.group(:scheme).where("scheme_id in (?)", schemes).sum(:total_points)
    schemes.collect { |scheme| SchemeBudget.new(scheme, total_points_per_scheme) }
  end

  private
  def order_items
    OrderItem.where(:scheme_id => @scheme.id).valid_orders
  end

  def rupee_ratio
    @scheme.client.points_to_rupee_ratio
  end

end