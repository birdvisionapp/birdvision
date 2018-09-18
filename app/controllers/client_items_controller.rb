class ClientItemsController < ApplicationController
  before_filter :authenticate_user!

  def show
    client_item = ClientItem.with_level_clubs(@user_scheme.applicable_level_clubs).active_items.find_by_slug!(params[:slug])
    @user_item = UserItem.new(@user_scheme, client_item, client_item.item_redeemable?(@user_scheme))
    @catalogs = @user_scheme.catalogs
  end
end