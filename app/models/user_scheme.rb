class UserScheme < ActiveRecord::Base
  has_paper_trail
  belongs_to :user, :inverse_of => :user_schemes
  belongs_to :scheme
  has_many :targets, :autosave => true
  has_one :cart
  belongs_to :level
  belongs_to :club

  attr_accessible :user_id, :scheme_id, :total_points, :redeemed_points,
    :current_achievements, :region, :level, :club, :targets, :notify_points_update
  
  attr_accessor :notify_points_update

  validates :total_points, :numericality => {:greater_than_or_equal_to => 0}
  validates :redeemed_points, :numericality => {:greater_than_or_equal_to => 0}
  validates :current_achievements, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true
  validates :level, :presence => true

  after_save :send_notification
  after_save :update_transaction
  after_create :create_cart

  scope :for_user, lambda { |user, scheme_slug| includes(:scheme).where('user_id = ? AND schemes.slug = ?', user.id, scheme_slug) }
  scope :clubbable, lambda { includes(:scheme).where('schemes.single_redemption = ?', false) }
  scope :browsable, lambda { includes(:scheme).where('schemes.start_date <= :today AND schemes.redemption_end_date >= :today', :today => Date.today) }

  validate :level_name_inclusion
  validate :club_name_inclusion

  def level_name_inclusion
    return unless level.present?
    level_names = scheme.levels.collect(&:name)
    errors.add(:level, "Level should be one of the following: #{level_names.join(", ")}") unless level_names.include? level.name
  end

  def club_name_inclusion
    return unless club.present?
    club_names = scheme.clubs.collect(&:name)
    errors.add(:club, "Club should be one of the following: #{club_names.join(", ")}") unless club_names.include? club.name
  end

  def send_notification
    return unless user.status.downcase == User::Status::ACTIVE
    is_points_deducted, points_deducted = points_deducted_trans
    if is_points_deducted == true
      UserSchemeNotifier.notify_points_deduction(self, points_deducted.abs)
    else
      UserSchemeNotifier.notify(self)
    end
  end

  def update_transaction
    puts "*****************update_transaction***********************"
    puts self.inspect
    unless self.single_redemption?
      if self.total_points > self.total_points_was
        puts "*********update_transaction - CREDIT*****************"
        puts self.total_points
        puts self.total_points_was
        transaction_action, points = SchemeTransaction::Action::CREDIT, (self.total_points - self.total_points_was)
      end
      is_points_deducted, points_deducted = points_deducted_trans
      if self.total_points < self.total_points_was
        puts "*********update_transaction - DEBIT*****************"
        puts self.total_points
        puts self.total_points_was
        transaction_action, points = SchemeTransaction::Action::DEBIT, (self.total_points_was - self.total_points)
      elsif is_points_deducted == true
        puts "*********update_transaction - DEBIT-ELSE - points_deducted_trans*****************"
        puts points_deducted
        transaction_action, points = SchemeTransaction::Action::DEBIT, points_deducted
      end
      SchemeTransaction.record(self.scheme.id, transaction_action, self, points.abs.to_i) if transaction_action.present?
    end
  end

  def points_deducted_trans
    unless self.single_redemption?
      return true, (self.redeemed_points_was - self.redeemed_points) if user.client.allow_total_points_deduction? && self.redeemed_points > self.redeemed_points_was
    end
    return false, 0
  end

  def redemption_active?
    scheme.redemption_active?
  end

  def redemption_over?
    scheme.redemption_over?
  end

  def browsable?
    scheme.browsable?
  end

  def barometer
    Barometer.new(self)
  end

  def has_sufficient_points?
    return true if single_redemption?
    user.total_redeemable_points >= cart.total_points
  end

  def redeem
    unless single_redemption?
      self.update_attributes!(:redeemed_points => (redeemed_points.presence||0) + cart.total_points)
    end
    cart.clear
  end

  def can_redeem?
    club.present? && redemption_active? && can_add_to_cart?
  end

  def can_add_to_cart?
    order_item_for_user_scheme = OrderItem.for_user_scheme(self)
    !(single_redemption? && order_item_for_user_scheme.count > 0 && order_item_for_user_scheme.any?(&:not_refunded?))
  end

  def can_place_order?
    redemption_active? && !cart.empty? && has_sufficient_points?
  end

  def applicable_level_clubs
    scheme.level_clubs.includes(:club).where(:level_id => level).order("clubs.rank asc")
  end

  def orders_total
    OrderItem.for_user_scheme(self).sum(&:price_in_rupees).to_i
  end

  def show_points?
    scheme.show_points?
  end

  def single_redemption?
    scheme.single_redemption?
  end

  def minimum_points
    to_points(active_items(applicable_level_clubs).minimum("client_items.client_price"))
  end

  def maximum_points
    to_points(active_items(applicable_level_clubs).maximum("client_items.client_price"))
  end

  def catalogs
    LevelClubCatalogs.new(self)
  end

  private
  def to_points(price)
    (price.to_i * scheme.client.points_to_rupee_ratio).to_i
  end

  def active_items(level_clubs)
    level_clubs.includes(:client_items).merge(ClientItem.active_items)
  end

end