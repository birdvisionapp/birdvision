class Admin::MasterCatalogController < Admin::AdminController
  #authorize_resource :class => Admin::MasterCatalogController
  include AverageMarginCalculator
  inherit_resources
  actions :all, :except => [:destroy, :new, :show]
  defaults :resource_class => Item, :collection_name => 'items', :instance_name => 'item'
  load_and_authorize_resource :class => Item

  def index
    default_sort = 'updated_at desc'
    respond_to do |format|
      format.html {
        items_que = Item.accessible_by(current_ability).includes(:category => :msp, :preferred_supplier => :supplier, :item_suppliers => :supplier)
        items_que = items_que.client_items_avail if params[:q] && params[:q][:client_items_client_id_eq].present?
        @search = items_que.search(params[:q])
        @search.sorts = default_sort if @search.sorts.empty?
        search_result = @search.result(:distinct => true)
        @items = search_result.page(params[:page]).per(10)
        @average_bvc_margin = calculate_bvc_margin @search.result
      }
      format.csv {
        process_csv_report("Master Catalog #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "Item.accessible_by(current_ability).includes(:category => :msp, :preferred_supplier => :supplier, :item_suppliers => :supplier).#{(params[:q] && params[:q][:client_items_client_id_eq].present?) ? 'client_items_avail.' : ''}search(#{params[:q]})", default_sort: default_sort)
      }
    end
  end

  def update
    update! { admin_master_catalog_index_path(:q => params[:q]) }
  end

  def toggle_status
    item_ids = params[:item_ids]
    action = 'active' if params[:active]
    action = 'inactive' if params[:inactive]
    item_group_action(item_ids, action) unless action.nil?
    flash.keep
    redirect_to admin_master_catalog_index_path(:q => params[:q])
  end

  def upload_csv
    return redirect_to import_csv_admin_master_catalog_index_path, :alert => App::Config.messages[:master_catalog][:file_not_provided] unless params[:csv].present?
    async_job = current_admin_user.async_jobs.create(:job_owner => Item.name, :csv => params[:csv], :status => AsyncJob::Status::PROCESSING)
    unless async_job.valid?
      flash[:alert] = App::Config.messages[:master_catalog][:invalid_csv_file]
      redirect_to import_csv_admin_master_catalog_index_path and return
    end
    async_job.delay.execute
    flash[:notice] = App::Config.messages[:master_catalog][:processed_successfully]
    redirect_to admin_uploads_index_path
  end

  private

  def interpolation_options
    {:resource_description => @item.title}
  end

  def item_group_action(item_ids, message_slug)
    if item_ids.nil?
      flash[:alert] = App::Config.messages[:master_catalog][:no_items_selected] % message_slug.titleize
    else
      Item.accessible_by(current_ability).where(['id IN(?)', item_ids]).update_all({:status => message_slug})
      flash[:notice] = App::Config.messages[:master_catalog]["successful_#{message_slug}".to_sym] % item_ids.length
    end
  end

end
