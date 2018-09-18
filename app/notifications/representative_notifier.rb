class RepresentativeNotifier
  
  def self.notify_daily_status(client_admin)
    unless client_admin.client_id == 191
      linkable_ids = client_admin.users.pluck(:id)
      date = Date.yesterday
      new_registrations = UniqueItemCode.joins(:user, :product_code_link).used.where('product_code_links.linkable_type = ? AND product_code_links.linkable_id IN(?) AND (users.status = ? OR (users.status=? AND DATE(unique_item_codes.used_at) = ?))', 'User', linkable_ids, 'pending', 'active', date).select('DISTINCT unique_item_codes.user_id').count
      used_codes = UniqueItemCode.joins(:user, :reward_item_point, :product_code_link).where('product_code_links.linkable_type = ? AND product_code_links.linkable_id IN(?) AND users.status = ? AND DATE(unique_item_codes.used_at) <= ?', 'User', linkable_ids, 'active', date)
      sales_volume = SalesVolume.new(used_codes)
      ClientAdminMailer.delay.notify_daily_status(client_admin, date) if client_admin.email.present?
      SmsMessage.new(:representative_notify_daily_status, :to => client_admin.mobile_number, :user => client_admin.name, :pending_requests => new_registrations, :sales_volume => sales_volume.total_sales_volume, :client => client_admin.client.client_name).delay.deliver if client_admin.mobile_number.present?
    end
  end

end