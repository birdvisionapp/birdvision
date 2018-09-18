module PointRangeCalculator
  def point_range_for(user_scheme, search_stats={}, search_params={})
    range_min =  search_stats.include?("min") ? search_stats["min"].to_i : user_scheme.minimum_points
    range_max =  search_stats.include?("max") ? search_stats["max"].to_i : user_scheme.maximum_points
    selected_min = search_params.include?('point_range_min') ? [search_params['point_range_min'].to_i,range_min].max : range_min
    selected_max = search_params.include?('point_range_max') ? [search_params['point_range_max'].to_i,range_max].min : range_max

    {:min => range_min, :max => range_max, :selected_min => selected_min, :selected_max => selected_max}
  end
end