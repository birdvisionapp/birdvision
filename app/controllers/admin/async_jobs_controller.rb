class Admin::AsyncJobsController < Admin::AdminController
  load_and_authorize_resource

  inherit_resources
  actions :index, :destroy

  def index
    @async_jobs = AsyncJob.includes((is_admin_user?) ? :admin_user : []).accessible_by(current_ability).select('async_jobs.id, async_jobs.csv_file_name, async_jobs.job_owner, async_jobs.status, async_jobs.created_at, async_jobs.csv_errors, async_jobs.admin_user_id').order('async_jobs.created_at desc').page(params[:page])
  end
  
  def destroy
    destroy! { admin_uploads_index_path }
  end
end
