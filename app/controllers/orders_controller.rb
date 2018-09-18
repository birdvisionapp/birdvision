class OrdersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :hide_search
  before_filter :check_otp, :only => [:create]

  def index
    @orders = current_user.orders.order("created_at desc").page(params[:page])
  end

  def new
    redirect_to carts_path and return if @user_scheme.cart.empty? || !@user_scheme.has_sufficient_points?
    @order = @user_scheme.cart.build_order_for(@user_scheme.scheme)
    @user = @user_scheme.user
  end

  def create_preview
    session[:order] = params[:order]
    @order = @user_scheme.cart.build_order_for(@user_scheme.scheme, session[:order])
    if @order.valid?
      current_user.send_one_time_password if current_user.client.allow_otp?
      redirect_to order_preview_path(:scheme_slug => @user_scheme.scheme.slug)
    else
      render :new, :locals => {:scheme_slug => params[:scheme_slug]}
    end
  end

  def preview
    @order = @user_scheme.cart.build_order_for(@user_scheme.scheme, session[:order])
  end

  def create
    @order = @user_scheme.cart.build_order_for(@user_scheme.scheme, session[:order])
    if @order.place_order(@user_scheme)
      OrderNotifier.notify_confirmation(@order, @user_scheme)
      session[:order] = nil
      redirect_to order_path(:id => @order, :scheme_slug => @user_scheme.scheme.slug), :notice => App::Config.messages[:order][:confirmation]
    else
      redirect_to carts_path
    end
  end

  def show
    @order = current_user.orders.find(params[:id])
    flash.now[:notice] = App::Config.messages[:order][:confirmation]
  end

  def hide_search
    @hide_search = true
  end

  def send_otp
    if current_user.client.allow_otp?
      current_user.send_one_time_password
      flash[:notice] = App::Config.messages[:order][:sent_otp_confirmation] % view_context.otp_sending_option
    else
      flash[:alert]= App::Config.errors[:order][:otp_not_enabled] % view_context.current_user_client_name
    end
    redirect_to order_preview_path(:scheme_slug => @user_scheme.scheme.slug)
  end

  private

  def check_otp
    return nil unless current_user.client.allow_otp?
    unless params[:user][:otp].present?
      flash[:alert]= App::Config.errors[:order][:otp_blank] % view_context.otp_sending_option
      redirect_to order_preview_path(:scheme_slug => @user_scheme.scheme.slug) and return
    end
    unless current_user.check_one_time_password(params[:user][:otp])
      flash[:alert]= App::Config.errors[:order][:invalid_otp]
      redirect_to order_preview_path(:scheme_slug => @user_scheme.scheme.slug) and return
    end 
  end

end