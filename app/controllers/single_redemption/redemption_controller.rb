class SingleRedemption::RedemptionController < ApplicationController
  before_filter :authenticate_user!

  def redeem
    client_item = ClientItem.with_level_clubs(@user_scheme.applicable_level_clubs).active_items.includes(:item).active_item.find_by_slug(params[:id])
    unless client_item && client_item.item_redeemable?(@user_scheme)
      head :unauthorized
      return
    end
    @user_scheme.cart.clear
    @user_scheme.cart.add_client_item(client_item)
    @user_scheme.cart.save!
    redirect_to new_order_path(:scheme_slug => @user_scheme.scheme.slug)
  end
end