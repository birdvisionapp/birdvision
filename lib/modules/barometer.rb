class Barometer
  def initialize(user)
    @user = user
  end

  def remaining_points
    @total_points ||= @user.total_redeemable_points
  end

  def redeemed_points
    @redeemed_points ||= @user.total_redeemed_points
  end

  def percent_redeemed
    return 0 if total_points.zero?
    (redeemed_points*100/total_points)
  end

  def percent_remaining
    100 - percent_redeemed
  end

  private
  def total_points
    redeemed_points + remaining_points
  end

end