class SmsBasedDashboard

  def initialize(admin_user)
    @current_ability = Ability.new(admin_user)
  end

  def product_stats
    products.group(:status).count
  end

  def product_pack_stats
    product_packs.group('reward_item_points.status').count
  end

  def unique_code_stats
    {
      :used => unique_codes.used.select(:id).count,
      :unused => unique_codes.unused.select(:id).count
    }
  end

  def participant_stats
    users.sms_based.group(:status).count
  end

  def pack_size_stats
    {
      :total => PackSize.accessible_by(current_ability).count,
    }
  end

  def total_reward_categories
    RewardProductCatagory.accessible_by(current_ability).count
  end

  private
  
  def products
    @products ||= RewardItem.accessible_by(current_ability)
  end

  def product_packs
    @product_packs ||= RewardItemPoint.accessible_by(current_ability)
  end

  def unique_codes
    @unique_codes ||= UniqueItemCode.accessible_by(current_ability)
  end

  def users
    @users ||= User.includes(:client).accessible_by(current_ability)
  end

  def current_ability
    @current_ability
  end

end
