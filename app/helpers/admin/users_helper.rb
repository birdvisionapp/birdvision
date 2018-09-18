module Admin::UsersHelper

  def email_password_reset_instructions_to(user_ids)
    user_ids.each do |user_id|
      @user = User.generate_activation_token_for user_id
      UserNotifier.notify_activation(@user)
    end
  end

  #TODO - (KD, Geet) Being done for html view -- the caller should have ViewsHelper included, bvc currency not required for csv, find better way to avoid repetition
  def points_per_scheme(user)
    user.user_schemes.collect { |user_scheme| "#{user_scheme.scheme.name} (#{bvc_currency(user_scheme.total_points)})" }.join("<br/>")
  end

  def points_per_scheme_csv(user)
    user.user_schemes.collect { |user_scheme| "#{user_scheme.scheme.name} (#{user_scheme.total_points})" }.join(", ")
  end

  def display_time_stamp_details(resource)
    text = ''
    ['created_at', 'updated_at'].each do |action|
      text += content_tag(:dt, action.titleize)
      text += content_tag(:dd, l(resource.send(action.to_s), :format => :long_date_time) || '')
    end
    return text.html_safe
  end

end