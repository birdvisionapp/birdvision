class SalesVolume

  def initialize(used_codes)
    @used_codes = used_codes
  end

  def total_memebrs_registered
    @used_codes.map(&:user).uniq.count
  end

  def total_points_earned
    sales.map{|s| s[:points] }.sum
  end

  def total_sales_volume
    sales_volume = sales.group_by{|s| s[:metric] }.map{|k, v| "#{v.map{|s| s[:pack_size].to_f }.sum} #{k.upcase}" }
    sales_volume.join(', ')
  end

  private

  def sales
    @sales ||= @used_codes.map(&:reward_item_point).map{|r| {pack_size: r.pack_size, metric: r.metric, points: r.points} }
  end

end
