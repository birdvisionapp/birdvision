class UserSchemeNotifier

  def self.notify(user_scheme)
    user = user_scheme.user
    scheme = user_scheme.scheme
    change_hash = build_changes_hash(user_scheme)

    if change_hash.present?
      UserMailer.delay.account_update(user, scheme.name, change_hash) if user.email.present? && user.activation_status == User::ActivationStatus::ACTIVATED
      return nil unless user.mobile_number.present?
      parameters = {:to => user.mobile_number, :scheme => scheme.name, :client => user.client.client_name}
      if change_hash[:total_points].present?
        SmsMessage.new(:user_scheme_points_update, parameters.merge!(:points => user_scheme.total_points, :balance => user.total_redeemable_points)).delay.deliver
      else
        SmsMessage.new(:user_scheme_info_update, parameters.merge!(:changes=> sms_changes_text(change_hash))).delay.deliver
      end
    end
  end

  def self.notify_points_deduction(user_scheme, points_deducted)
    user = user_scheme.user
    balance = user.total_redeemable_points
    UserMailer.delay.total_points_deduction(user_scheme, points_deducted, balance) if user.email.present?
    SmsMessage.new(:total_points_deduction, :to => user.mobile_number, :client => user.client.client_name, :points => points_deducted, :balance => balance).delay.deliver if user.mobile_number.present?
  end

  private
  def self.build_changes_hash(user_scheme)
    change_hash = {}
    current_achievements = user_scheme.current_achievements.present? ? user_scheme.current_achievements : '0'
    change_hash[:current_achievements] = current_achievements if send_achievements_changed_notif?(user_scheme)
    change_hash[:total_points] = user_scheme.total_points if send_points_changed_notif?(user_scheme)
    change_hash[:club] = user_scheme.club.name if send_club_changed_notif?(user_scheme)
    change_hash
  end

  def self.sms_changes_text(change_hash)
    change_hash.map { |key, value| "#{key.to_s.humanize}: #{value}" }.join(', ')
  end

  def self.send_achievements_changed_notif?(user_scheme)
    user_scheme.current_achievements.present? && (user_scheme.current_achievements_changed? || user_scheme.id_changed?)
  end

  def self.send_points_changed_notif?(user_scheme)
    user_scheme.total_points.present? && user_scheme.show_points? && (user_scheme.id_changed? || user_scheme.total_points_changed?)
  end

  def self.send_club_changed_notif?(user_scheme)
    user_scheme.club.present? && user_scheme.scheme.clubs.count > 1 && user_scheme.club_id_changed?
  end
end