class Admin::AlTransactionsController < Admin::AdminController

  layout "admin"
  before_filter :authenticate_admin_user!

  def index
  end

  def al_reward_product_points_upload
    async_job = current_admin_user.async_jobs.create(:job_owner => AlTransaction.name, :csv => params[:csv], :status => AsyncJob::Status::PROCESSING)
    async_job.delay.add_product_points
    redirect_to admin_uploads_index_path
  end
  
  def al_reward_product_points_template
    respond_to { |format|
      format.csv { send_data CsvRewardProductPoint.new(current_admin_user).template, :filename => "AL reward product csv template.csv" }
    }
  end
  
  def failed_transaction
    respond_to do |format|
      format.html {
        @search = AlTransactionIssue.accessible_by(current_ability).search(params[:q])
        @search.sorts = 'created_at desc' if @search.sorts.empty?
        @failed_transaction = @search.result.page(params[:page])
      }
      format.csv {
        process_csv_report("AL Unsuccessful Uploads #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "AlTransactionIssue.accessible_by(current_ability).search(#{params[:q]})")
      }
    end
  end

  def successful_transaction
    respond_to do |format|
      format.html {
        @search = AlTransaction.accessible_by(current_ability).search(params[:q])
        @search.sorts = 'created_at desc' if @search.sorts.empty?
        @successful_transaction = @search.result.page(params[:page])
      }
      format.csv {
        process_csv_report("AL Successful Uploads #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "AlTransaction.accessible_by(current_ability).search(#{params[:q]})")
      }
    end
  end

  def parse
    async_job = current_admin_user.async_jobs.create(:job_owner => AlTransaction.name, :csv => params[:csv], :status => AsyncJob::Status::PROCESSING)
    async_job.delay.execute_al_transaction
    redirect_to admin_uploads_index_path
  end
  
  def al_channel_linkage
    @search = AlChannelLinkage.search(params[:q])
    @search.sorts = 'created_at desc' if @search.sorts.empty?
    @acl = @search.result.page(params[:page])
    # @acl = AlChannelLinkage.page(params[:page])
  end
  
  def edit_al_linkage
    @acl = AlChannelLinkage.find(params[:id])
  end
  
  def update_al_linkage
    @acl = AlChannelLinkage.find(params[:id])
    if @acl.update_attributes(params[:al_channel_linkage])
      redirect_to al_channel_linkage_admin_al_transactions_path  
    else
      render :edit_al_linkage
    end
  end
  
  def delete_al_linkage
    @acl = AlChannelLinkage.find(params[:id])
    @acl.delete
    redirect_to al_channel_linkage_admin_al_transactions_path
  end
  
  def channel_linkage_template
    respond_to { |format|
      format.csv { send_data AlChannelLinkageCsv.new(current_admin_user).template, :filename => "AL channel linkage csv template.csv" }
    }
  end
  
  def parse_channel_linkage
    async_job = current_admin_user.async_jobs.create(:job_owner => AlTransaction.name, :csv => params[:csv], :status => AsyncJob::Status::PROCESSING)
    async_job.delay.execute_al_channel_linkage
    redirect_to admin_uploads_index_path
  end
    
end
