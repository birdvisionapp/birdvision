class Admin::SmsBased::UniqueItemCodesController < Admin::AdminController

  load_and_authorize_resource

  skip_authorize_resource :only => [:report, :track, :print_preview, :coupons_preview, :download, :link, :download_linkable]

  inherit_resources

  actions :index, :create

  before_filter :load_language_templates, :only => [:index]

  before_filter :load_product_pack, :only => [:load_multi_tier, :multi_tier_conf]

  before_filter :load_unsed_codes, :only => [:print_preview, :coupons_preview]

  before_filter :load_user_roles, :only => [:link]

  def index
    @search = UniqueItemCode.accessible_by(current_ability).search(params[:q])
    #@search.sorts = 'unique_item_codes.pack_number asc' if @search.sorts.empty?
    @unused_codes_count = @search.result.unused.select(:id).count
    @used_codes_count = @search.result.used.select(:id).count
    respond_to do |format|
      format.html
      format.csv {
        process_csv_report("Unused Product Codes Report #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "UniqueItemCode.unused.inc.accessible_by(current_ability).search(#{params[:q]})", default_sort: 'created_at desc')
      }
    end
  end

  def track
    @unique_item_code = UniqueItemCode.includes(:reward_item_point).accessible_by(current_ability).for_code(params[:product_code]).first if params[:product_code].present?
  end

  def report
    @search = UniqueItemCode.used.includes(:user, :reward_item_point => {:reward_item => [:client, :scheme]}).accessible_by(current_ability).select('unique_item_codes.id, unique_item_codes.reward_item_point_id, unique_item_codes.code, unique_item_codes.user_id, unique_item_codes.used_at').search(params[:q])
    @search.sorts = 'used_at desc' if @search.sorts.empty?
    @unique_item_codes = @search.result.page(params[:page])
    respond_to do |format|
      format.html
      format.csv {
        process_csv_report("Used Product Codes Report #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "UniqueItemCode.used.includes(:product_code_link => {:linkable => :user_role}, :user => :user_role, :reward_item_point => {:reward_item => [:client, :scheme]}).accessible_by(current_ability).search(#{params[:q]})", default_sort: 'used_at desc', method_options: {dync_param: 'used_'} )
      }
    end
  end

  def create
    @unique_item_code = UniqueItemCode.new(params[:unique_item_code])
    if @unique_item_code.valid?
      number_of_codes = @unique_item_code.number_of_codes
      reward_item_point = @unique_item_code.reward_item_point
      UniqueItemCode.delay.generate_unique_codes(reward_item_point.id, number_of_codes, @unique_item_code.expiry_date, params[:unique_item_code][:code_packs].to_i || 0) if reward_item_point.present?
      flash[:notice] = App::Config.messages[:unique_item_codes][:generating_codes] % [number_of_codes, reward_item_point.product_detail]
      redirect_to admin_sms_based_reward_item_points_path
    else
      render action: "new"
    end
  end

  def load_multi_tier
    @tiers_count ||= (1..@product_pack.reward_item.client.user_roles_main.select(:id).count).to_a if @product_pack.reward_item.client.user_roles_main.present?
    render :layout => false
  end

  def multi_tier_conf
    @tiers = params[:tiers]
    @tiers.to_i.times { @product_pack.pack_tier_configs.build } unless @product_pack.pack_tier_configs.present?
    render :layout => false
  end

  def print_preview
    @languages = params["language"].values.uniq
    @languages.reject!(&:empty?)
    @total_codes = @search.result.count
  end

  def coupons_preview
    send_data @search.result.limit(30).to_pdf({languages: params[:languages]}), disposition: 'inline', type: 'application/pdf'
  end

  def download
    content_type = params[:print_format]
    process_csv_report("Product-Codes-For-Print-#{content_type.upcase}-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.#{content_type}", model_query: "UniqueItemCode.unused.inc.accessible_by(current_ability).search(#{params[:q]})", content_type: content_type, method_options: {languages: params[:languages]})
  end

  def download_linkable
    process_csv_report("Linked Product Codes #{Time.now.strftime('%Y-%m-%d %H-%M-%S')}.csv", model_query: "ProductCodeLink.unused.includes(:linkable, :unique_item_code => {:reward_item_point => :reward_item}).accessible_by(current_ability).where('product_code_links.linkable_type=?', 'User').search(#{params[:q]})")
  end

  private

  def load_unsed_codes
    @search = UniqueItemCode.unused.inc.accessible_by(current_ability).select('unique_item_codes.id, unique_item_codes.reward_item_point_id, unique_item_codes.code').search(params[:q])
  end

  def load_product_pack
    @product_pack ||= RewardItemPoint.includes(:reward_item).accessible_by(current_ability).find(params[:source_id])
  end

  def load_language_templates
    @language_templates = LanguageTemplate.accessible_by(current_ability).active.select([:id, :name]).map{|l|[l.name, l.id]}
  end

end