class Admin::DownloadReportsController < Admin::AdminController

  load_and_authorize_resource

  inherit_resources

  actions :index, :destroy

  def index
    @download_reports = DownloadReport.includes((is_super_admin?) ? :admin_user : []).accessible_by(current_ability).select('download_reports.id, download_reports.filename, download_reports.url, download_reports.status, download_reports.created_at, download_reports.report_errors, download_reports.admin_user_id').order('download_reports.created_at desc').page(params[:page])
  end

  def destroy
    destroy! { admin_download_reports_path }
  end

  def download
    download_report = DownloadReport.select(:url).accessible_by(current_ability).find(params[:download_report_id])
    redirect_to download_report.url
  end

  private

  def interpolation_options
    {:resource_description => @download_report.filename}
  end

end
