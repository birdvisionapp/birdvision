class UserRegistrationsController < ApplicationController

  include Devise::Controllers::Helpers

  layout "user"

  skip_authorize_resource

  before_filter :check_sign_up_enabled
  def new
    if current_user.nil? && current_admin_user.nil?
      @user = User.new
      @linkages = User.where('user_role_id = ?', @this_client_customization.user_role_id)
    else
      flash[:alert] = "Please sign out to proceed"
      redirect_to admin_dashboard_path if current_user.nil? 
      redirect_to schemes_path if current_admin_user.nil?
    end
  end

  def create
    params_hash = params[:user]
    coupen_code = params_hash["coupen_code"]
    parent = params_hash["parent_id"]
    mobile_number = params[:user][:mobile_number]
    check_code = UniqueItemCode.unused.joins(reward_item_point: :reward_item).select('reward_items.client_id, unique_item_codes.id').where(unique_item_codes: {:code => coupen_code})
    not_expired = UniqueItemCode.find(check_code).expiry_date > Date.today unless check_code.empty? 
    check_client = (check_code.first.client_id == @this_client.id) unless check_code.empty?
    if (!check_code.empty? && not_expired && check_client) || !params[:user][:schemes].nil? #go in also if scheme id entered
      params_hash["participant_id"] = mobile_number
      params_hash["client_id"] = @this_client.id
      params_hash["activation_status"] = "Activated"
      this_scheme_id = params_hash["schemes"].to_i #stored scheme id in other variable
      scheme = Scheme.find(this_scheme_id) unless this_scheme_id == 0 
      params_hash["status"] = "active"      #params_hash["user_role_id"] = 1731
      @user = User.new(params_hash)
      client_code = Client.find(params_hash["client_id"].to_i).code
      check_username = User.where(:username => User.build_username_with_participant(client_code, mobile_number))
      if check_username.empty?
        if @user.save
          flash[:success] = App::Config.messages[:participant][:registration_success]% [@this_client.client_name]
          customization = UserCustomization.new
          parent = nil if parent == ""
          if coupen_code.present?
            customization.user_registration_update(coupen_code, @user, parent)
          else
            customization.user_scheme_update(@user, scheme)
          end
          sign_in :user, @user
          redirect_to schemes_path
        else
          flash[:alert] = App::Config.messages[:participant][:error_while_register]
          redirect_to new_user_registration_path  
        end
     else
        flash[:alert] = App::Config.messages[:participant][:existing_user]
        redirect_to new_user_registration_path
     end
    else
      flash[:alert] = App::Config.messages[:participant][:invalid_coupon_code]
      redirect_to new_user_registration_path
    end
  end

  private

  def check_sign_up_enabled
    url = request.host
    @this_client = Client.find(:all, :conditions=>['domain_name LIKE ?', "%#{url}%"]).first #.client_customization.coupen_code_enabled
    unless @this_client.nil?
      unless @this_client.client_customization.nil?
        @this_client_customization = @this_client.client_customization
        if @this_client_customization.sign_up_enabled?
          @is_code_allowed = @this_client_customization.coupen_code_enabled
        else
          flash[:alert] = App::Config.messages[:participant][:web_enrollment_disabled]% [@this_client.client_name]
          redirect_to new_user_session_path
        end
      else
        flash[:alert] = App::Config.messages[:participant][:web_enrollment_disabled]% [@this_client.client_name]
        redirect_to new_user_session_path
      end
    else
      flash[:alert] = App::Config.messages[:participant][:wrong_url]
      redirect_to new_user_session_path
    end
  end

end
