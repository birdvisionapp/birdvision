module Admin::TemplatesHelper

  def enable_template?
    current_admin_user.role == AdminUser::Roles::SUPER_ADMIN and !current_admin_user.msp_id.present?
  end
end
