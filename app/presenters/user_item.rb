class UserItem
  extend Forwardable
  def_delegators :@client_item, :slug, :item, :price_to_points
  attr_accessor :client_item, :user_scheme

  def initialize(user_scheme, client_item, redeemable)
    @user_scheme = user_scheme
    @client_item = client_item
    @redeemable = redeemable
  end

  def scheme_slug
    @user_scheme.scheme.slug
  end

  def single_redemption?
    @user_scheme.single_redemption?
  end

  def redeemable?
    @redeemable
  end

  def to_param
    slug
  end
end