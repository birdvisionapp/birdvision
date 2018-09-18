require 'open-uri'
class AsyncJob < ActiveRecord::Base

  module Status
    PROCESSING = 'processing'
    FAILED = 'failed'
    SUCCESS = 'success'
    ALL = [PROCESSING, FAILED, SUCCESS]
  end

  # Associations
  belongs_to :admin_user

  attr_accessible :csv, :job_owner, :status
  validates :csv, :presence => true
  serialize :csv_errors

  has_attached_file :csv, :bucket => ENV['ASYNC_UPLOAD_BUCKET'], :s3_protocol => 'https'
  validates_attachment_content_type :csv, :content_type => ['text/csv', 'application/octet-stream',
                                                            'text/comma-separated-values', 'application/csv', 'application/excel',
                                                            'application/vnd.ms-excel', 'application/vnd.msexcel']

  def execute(association_id = nil, opts = {})
    begin
      job_owner.constantize.create_many_from_csv(open(csv.url), association_id, opts)
      self.status = AsyncJob::Status::SUCCESS
    rescue Exceptions::File::InvalidFileType, Exceptions::File::InvalidCSVFormat
      self.csv_errors = {:message => App::Config.messages[:async_uploads][:invalid_file]}
      self.status = AsyncJob::Status::FAILED
    rescue Exceptions::File::DuplicateEntityInCsv => error
      @duplicate_ids = error.ids
      self.csv_errors = {:message => App::Config.messages[:async_uploads][:duplicate_record] % @duplicate_ids.to_s}
      self.status = AsyncJob::Status::FAILED
    rescue Exceptions::File::ErrorsInCsv => error
      error_hash = error.data
      self.csv_errors = error_hash.each { |row_number, errors| error_hash[row_number] = errors.full_messages }
      self.status = AsyncJob::Status::FAILED
    end
    self.save!
  end
  
  def execute_al_transaction
    begin
      AlTransaction.update_points_for_sap_user(open(csv.url))
      self.status = AsyncJob::Status::SUCCESS
    rescue Exceptions::File::InvalidFileType, Exceptions::File::InvalidCSVFormat
      self.csv_errors = {:message => App::Config.messages[:async_uploads][:invalid_file]}
      self.status = AsyncJob::Status::FAILED
    end
    self.save!
  end
  
  def execute_al_channel_linkage
    begin
      AlChannelLinkage.update_channel_linkage(open(csv.url))
      self.status = AsyncJob::Status::SUCCESS
    rescue Exceptions::File::InvalidFileType, Exceptions::File::InvalidCSVFormat
      self.csv_errors = {:message => App::Config.messages[:async_uploads][:invalid_file]}
      self.status = AsyncJob::Status::FAILED
    end
    self.save!
  end
  
  def add_product_points
    begin
      AlTransaction.add_product_points_from_csv(open(csv.url))
      self.status = AsyncJob::Status::SUCCESS
    rescue Exceptions::File::InvalidFileType, Exceptions::File::InvalidCSVFormat
      self.csv_errors = {:message => App::Config.messages[:async_uploads][:invalid_file]}
      self.status = AsyncJob::Status::FAILED
    end
    self.save!
  end
end
