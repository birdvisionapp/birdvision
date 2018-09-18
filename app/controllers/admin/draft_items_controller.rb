class Admin::DraftItemsController < Admin::AdminController
  load_and_authorize_resource

  inherit_resources
  actions :all, :except => [:new]

  def index
    @search = DraftItem.accessible_by(current_ability).unpublished.search(params[:q])
    @draft_items = @search.result.order("updated_at desc").page(params[:page])
  end

  def upload_csv
    return redirect_to import_csv_admin_draft_items_path, :alert => App::Config.messages[:draft_item][:file_not_provided] unless params[:csv].present?
    return redirect_to import_csv_admin_draft_items_path, :alert => App::Config.messages[:draft_item][:no_supplier] unless params[:supplier].present?

    async_job = current_admin_user.async_jobs.create(:job_owner => DraftItem.name, :csv => params[:csv], :status => AsyncJob::Status::PROCESSING)

    unless async_job.valid?
      flash[:alert] = App::Config.messages[:draft_item][:invalid_csv_file]
      redirect_to import_csv_admin_draft_items_path and return
    end

    async_job.delay.execute(params[:supplier])
    flash[:notice] = App::Config.messages[:draft_item][:processed_successfully]
    redirect_to admin_uploads_index_path
  end

  def publish
    @draft_item = DraftItem.find(params[:draft_item_id])
    @item = @draft_item.publish
    render "show", alert: App::Config.messages[:draft_item][:item_cannot_be_moved] %@item.title and return unless @item.valid?
    redirect_to admin_draft_items_path, notice: App::Config.messages[:draft_item][:successful_publish] % @item.title
  end

  def lookup
    @draft_item = DraftItem.accessible_by(current_ability).find_by_id(params[:draft_item_id])
    return redirect_to admin_draft_items_path, alert: "The draft item does not exist" unless @draft_item.present?
    @items = Item.accessible_by(current_ability).title_like(params[:query].presence || @draft_item.title)
  end

  def link
    draft_item = DraftItem.accessible_by(current_ability).find(params[:draft_item_id])
    item = Item.accessible_by(current_ability).find(params[:item_id])
    supplier_name = Supplier.accessible_by(current_ability).find(draft_item.supplier_id).name

    if item.has_supplier? draft_item.supplier
      draft_item.destroy
      return redirect_to edit_admin_master_catalog_path(item.id), alert: supplier_name + " has already been associated with this item, hence supplier details have not been updated. Item deleted from draft."
    end

    draft_item.link_to(item)

    redirect_to edit_admin_master_catalog_path(item.id), notice: "Item has been successfully associated with supplier " + supplier_name
  end

  private

  def interpolation_options
    {:resource_description => @draft_item.title}
  end

end
