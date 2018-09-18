class CartsController < ApplicationController
  before_filter :authenticate_user!

  def add_item
    client_item = ClientItem.with_level_clubs(@user_scheme.applicable_level_clubs).active_items.includes(:item).active_item.find_by_slug(params[:id])
    if client_item.nil?
      flash[:alert] = App::Config.errors[:cart][:cart_item][:invalid_selection]
      redirect_to carts_path
    else
      @user_scheme.cart.add_client_item(client_item)
      current_user.save!
      redirect_to :action => :index
    end
    
  end

  def update_item_quantity
    client_item = @user_scheme.cart.cart_items.find(params[:cart_item][:id])
    flash[:alert] = client_item.errors.messages.values.flatten.join(',') unless client_item.update_quantity(params[:cart_item][:quantity])
    redirect_to carts_path
  end

  def remove_item
    client_item_to_delete = current_user.client.client_items.find(params[:id])

    @user_scheme.cart.remove_item(client_item_to_delete)
    flash[:notice] = App::Config.messages[:cart][:removed_item] % client_item_to_delete.item.title unless @user_scheme.cart.empty?
    flash.keep
    redirect_to :action => :index
  end

  def index
    @cart = @user_scheme.cart
    @cart.cart_items.includes(:client_item).each { |cart_item|
      @cart.remove_item(cart_item.client_item) if ClientItem.with_level_clubs(@user_scheme.applicable_level_clubs).active_items.includes(:item).active_item.where(:id => cart_item.client_item.id).empty?
    }
    @sufficient_points = @user_scheme.has_sufficient_points?
    flash.now[:info] = App::Config.messages[:cart][:insufficient_points] % (@cart.total_points - current_user.total_redeemable_points) unless @sufficient_points
    flash.now[:info] = App::Config.messages[:cart][:upcoming_scheme] % @user_scheme.scheme.name unless @user_scheme.scheme.redemption_active?
    flash.now[:info] = App::Config.messages[:cart][:empty] if @cart.empty?
  end
end