class DownloadReport < ActiveRecord::Base
  
  attr_accessible :report_errors, :filename, :status, :url

  has_paper_trail

  module Status
    PROCESSING = 'processing'
    FAILED = 'failed'
    SUCCESS = 'success'
    ALL = [PROCESSING, FAILED, SUCCESS]
  end

  REPORT_BUCKET_NAME = ENV['DOWNLOAD_REPORT_BUCKET']

  # Associations
  belongs_to :admin_user

  before_destroy :remove_report

  def remove_report
    return nil unless self.status == DownloadReport::Status::SUCCESS
    begin
      bucket = s3_object.buckets[REPORT_BUCKET_NAME]
      bucket.objects.delete(self.filename)
    rescue Exception => e
      Rails.logger.warn "Error: #{e.message}"
    end
  end

  def process(options = {})
    begin
      options.reverse_merge!(
        content_type: 'csv'
      )
      current_admin_user = self.admin_user
      current_ability = Ability.new(current_admin_user)
      role_options = {role: current_admin_user.role, is_super_admin: current_admin_user.super_admin? && !current_admin_user.msp_id.present?}
      role_options.merge!(options[:method_options]) if options[:method_options].present?
      if options[:resource_id].present? && options[:model].present?
        results = options[:model].constantize.accessible_by(current_ability).where(id: options[:resource_id]).to_csv(role_options)
      else
        model_query = options[:model_query]
        search = eval(model_query)
        search.sorts = options[:default_sort] if search.sorts.empty? && options[:default_sort].present?
        query_options = {}
        query_options.merge!(:distinct => true) unless model_query.include?("first.catalog.catalog_items.includes(:client_item")
        search_result = search.result(query_options)
        results = (options[:dyn_method].present?) ? current_admin_user.reseller.send(options[:dyn_method], search_result) : search_result.send("to_#{options[:content_type]}", role_options)
      end
      s3 = s3_object
      bucket_name = REPORT_BUCKET_NAME
      bucket = s3.buckets[bucket_name]
      unless bucket.exists?
        bucket = s3.buckets.create(bucket_name, :grants => {
            :grant_read => [{ :uri => "http://acs.amazonaws.com/groups/global/AllUsers" }]
          })
      end
      obj = bucket.objects[self.filename]
      obj.write(results)
      self.url = obj.url_for(:get, {
          expires: Time.now.tv_usec+100.months,
          response_content_disposition: 'attachment',
          response_content_type: "application/#{options[:content_type]}"
        }
      ).to_s
      self.status = DownloadReport::Status::SUCCESS
    rescue Exception => e
      self.report_errors = "Error: #{e.message}"
      self.status = DownloadReport::Status::FAILED
    end
    self.save
  end

  private

  def s3_object
    AWS::S3.new
  end

end
