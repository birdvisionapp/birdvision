class Api::ParticipantsController < Api::ApplicationController

  before_filter :authenticate_client

  before_filter :authenticate_user, :except => [:registration, :reset_password]

  before_filter :set_params, :only => [:registration, :update_info, :update_points]

  before_filter :update_points_steps, :only => [:update_points]

  before_filter :check_acceptance, :set_model_params, :only => [:registration, :update_info]

  before_filter :validate_registration, :only => :registration

  rescue_from Exception do |exception|
    render :json => json_status(2, exception.message)
  end

  def registration
    @user.registration_type = :send_activation_email if [1, "1"].include?(@params[:send_activation_email])
    if @user.save
      build_user_scheme(@params).save
      status_message = "The participant has successfully registered."
      status_message = "#{status_message} #{I18n.t('devise.confirmations.send_instructions')}" if @user.registration_type == :send_activation_email
      status_code = 0
    else
      status_code, status_message = 1, @user.errors.full_messages
    end
    render :json => json_status(status_code, status_message)
  end

  def rewards
    render :json => build_user_points_response
  end

  def update_info
    @user.assign_attributes(@model_params)
    if @user.save
      status_code, status_message = 0, "The participant has successfully updated"
    else
      status_code, status_message = 1, @user.errors.full_messages
    end
    render :json => json_status(status_code, status_message)
  end

  def de_activate
    if @user.update_attribute(:status, User::Status::INACTIVE)
      status_code, status_message = 0, 'The participant has successfully De-Activated'
    else
      status_code, status_message = 1, @user.errors.full_messages
    end
    render :json => json_status(status_code, status_message)
  end

  def update_points
    if build_user_scheme(@attr_hash).save
      status_code, status_message = 0, "The participant account has successfully updated"
    else
      status_code, status_message = 1, "Failed to update points to the participant: #{@user.username}"
    end
    render :json => json_status(status_code, status_message)
  end

  def forgot_password
    if @user.send_reset_password_instructions
      status_code, status_message = 0, I18n.t('devise.passwords.send_instructions')
    else
      status_code, status_message = 1, I18n.t('errors.messages.not_found')
    end
    render :json => json_status(status_code, status_message)
  end

  def reset_password
    if !request.headers['password'].present? || !request.headers['password_confirmation'].present?
      render :json => json_status(1, "Please enter valid password/password confirmation.")
      return
    end
    user = User.reset_password_by_token(reset_password_token: request.headers['reset_password_token'], password: request.headers['password'], password_confirmation: request.headers['password_confirmation'])
    if user.errors.empty?
      status_code, status_message = 0, I18n.t('devise.passwords.updated_not_active')
    else
      status_code, status_message = 1, user.errors.full_messages.join(", ")
    end
    render :json => json_status(status_code, status_message)
  end

  def login
    if @user.valid_password?(request.headers['password'])
      access_grant = @user.access_grants.create(:client_id => @client.id)    
      json = json_status(0, 'Access Token Generated').merge(access_token: access_grant.access_token)
    else
      json = json_status(1, I18n.t('devise.failure.invalid'))
    end
    render :json => json 
  end

  private

  def authenticate_client
    @client ||= Client.authenticate(request.headers['client_id'], request.headers['client_secret'])
    unless @client.present?
      render :json => json_status(1, 'Invalid client id or client secret')
      return
    end
  end

  def authenticate_user
    username = User.build_username_with_participant(@client.code, request.headers['participant_id'])
    @user ||= @client.users.where(:username => username).first
    unless @user.present?
      render :json => json_status(1, "Could not find BVC user account with ParticipantID: #{request.headers['participant_id']}")
      return
    end
    unless @user.status.downcase == User::Status::ACTIVE
      render :json => json_status(1, "The participant is in #{@user.status.upcase} status")
      return
    end
  end

  def build_user_points_response
    barometer = Barometer.new(@user)
    points = {points: {total: view_context.bvc_currency(@user.total_points_for_past_and_active_schemes), redeemed: view_context.bvc_currency(barometer.redeemed_points), remaining: view_context.bvc_currency(barometer.remaining_points)}}
    if @user.user_schemes.present?
      achievements = []
      @user.user_schemes.each do |user_scheme|
        achievements << {scheme_name: user_scheme.scheme.name, total: view_context.bvc_currency(user_scheme.current_achievements)} if user_scheme.current_achievements.present?
      end
    end
    (achievements.present?) ? points.merge!(achievements: achievements) : points
  end

  def check_acceptance
    checked_acceptable_params = check_acceptable_params((@user) ? 'update' : 'register')
    unless checked_acceptable_params ==  true
      render :json => json_status(1, checked_acceptable_params)
      return
    end
  end

  def set_params
    @params = ActiveSupport::HashWithIndifferentAccess.new(ActiveSupport::JSON.decode(request.body.read))
  end

  def set_model_params
    @model_params = @params.slice!(:level, :club, :participant_role, :scheme, :send_activation_email)
  end

  def validate_registration
    @user = @client.users.new(@model_params)
    if @user.participant_id.present? && @client.users.for_participant_id(@user.participant_id).present?
      render :json => json_status(1, "The participant has already registered with ParticipantID: #{@user.participant_id}")
      return
    end
    @user.status.downcase = User::Status::ACTIVE
    unless @client.one_user_role?
      participant_role = @client.user_roles.for_name(@params[:participant_role]).first
      if !@params[:participant_role].present? || !participant_role.present?
        render :json => json_status(1, "Please pass the valid ParticipantRole for new registration. e.g #{@client.user_roles.first.name}")
        return
      end
    else
      participant_role = @client.user_roles.first
    end
    @user.user_role = participant_role
    unless @client.one_scheme?
      @client_scheme = @client.schemes.for_name(@params[:scheme]).first
      if !@params[:scheme].present? || !@client_scheme.present?
        render :json => json_status(1, "Please pass the valid Scheme for new registration. e.g #{@client.schemes.first.name}")
        return
      end
    else
      @client_scheme = @client.schemes.first
    end
    unless @client_scheme.is_1x1?
      if !@params[:level].present? || !Level.with_scheme_and_level_name(@client_scheme, @params[:level]).present?
        render :json => json_status(1, "Please pass the valid Level of Scheme: #{@client_scheme.name} for new registration. e.g #{@client_scheme.levels.first.name}")
        return
      end
      if !@params[:club].present? || !Club.with_scheme_and_club_name(@client_scheme, @params[:club]).present?
        render :json => json_status(1, "Please pass the valid Club of Scheme: #{@client_scheme.name} for new registration. e.g #{@client_scheme.clubs.first.name}")
        return
      end
    end
  end

  def check_acceptable_params(action_label = '')
    param_keys = @params.keys
    acceptable_params = [:full_name, :email, :mobile_number, :landline_number, :address, :pincode, :notes]
    acceptable_params.unshift(:participant_role, :scheme, :level, :club, :participant_id, :send_activation_email) if action_label == 'register'
    param_keys.map!(&:to_sym)
    comparison = param_keys.all?{|k| acceptable_params.include?(k)}
    unless comparison
      return "The following parameters only can be acceptable in the JSON body to #{action_label.upcase} the Participant. Acceptable parameters: #{acceptable_params.to_sentence}. Unacceptable parameters: #{(param_keys - acceptable_params).to_sentence}"
    else
      true
    end    
  end

  def build_user_scheme(attr_hash = {})
    user_scheme = Csv::UserSchemeBuilder.new(@client_scheme, @user, true, attr_hash).build
    user_scheme = Csv::LevelClubBuilder.new(user_scheme, attr_hash).build
    targets = Csv::TargetBuilder.new(user_scheme, @client_scheme.clubs.collect { |club| "#{club.name}_start_target" }.uniq, attr_hash).build
    user_scheme
  end

  def update_points_steps
    param_keys = @params.keys
    acceptable_params = [:scheme, :action, :points]
    param_keys.map!(&:to_sym)
    comparison = param_keys.all?{|k| acceptable_params.include?(k)}
    unless comparison
      render :json => json_status(1, "The following parameters only can be acceptable in the JSON body. Acceptable parameters: #{acceptable_params.to_sentence}. Unacceptable parameters: #{(param_keys - acceptable_params).to_sentence}")
      return
    end

    unless @client.one_scheme?
      @client_scheme = @client.schemes.for_name(@params[:scheme]).first
      if !@params[:scheme].present? || !@client_scheme.present?
        render :json => json_status(1, "Please pass the valid Scheme. e.g #{@client.schemes.first.name}")
        return
      end
    else
      @client_scheme = @client.schemes.first
    end

    unless @params[:points].present? && params[:points] > 0
      render :json => json_status(1, "Please pass the valid points.")
      return
    end

    if @params[:action].present? && !['credit', 'debit'].include?(@params[:action])
      render :json => json_status(1, "Please pass the valid action. e.g credit/debit")
      return
    end
    action = @params[:action] || 'credit'
    @attr_hash = {"points" => @params["points"].to_i}
    @attr_hash["points"] = - @attr_hash["points"] if action == 'debit'
  end

end
