class ClientAdminMailer < ActionMailer::Base
  helper :mail_url, :views
  default :from => "no-reply@birdvision.in"
  include SendGrid

  def notify_daily_status client_admin, date
    sendgrid_category 'Representative Daily Status'
    sendgrid_unique_args :id => client_admin.id
    @client_admin = client_admin
    linkable_ids = @client_admin.users.pluck(:id)
    @new_registrations = UniqueItemCode.includes(:user, :product_code_link).used.where('product_code_links.linkable_type = ? AND product_code_links.linkable_id IN(?) AND (users.status = ? OR (users.status=? AND DATE(unique_item_codes.used_at) = ?))', 'User', linkable_ids, 'pending', 'active', date).group(:user_id)
    if @new_registrations.present?
      attachments['participants-registration-report.csv'] = {
        body: @new_registrations.registrations_to_csv
      }
    end
    @used_codes = UniqueItemCode.includes(:user, :reward_item_point, :product_code_link).where('product_code_links.linkable_type = ? AND product_code_links.linkable_id IN(?) AND users.status = ? AND DATE(unique_item_codes.used_at) <= ?', 'User', linkable_ids, 'active', date)
    if @used_codes.present?
      attachments['participants-performance-report.csv'] = {
        body: @used_codes.performance_to_csv
      }
    end
    @sales_volume = SalesVolume.new(@used_codes)
    mail :to => @client_admin.email, :subject => "#{@client_admin.client.client_name} Rewards Program - Daily Status - #{view_context.humanize_date(date)}", :template_path => "mailers/client_admin"
  end

end
