require 'spec_helper'

describe AsyncJob do
  it { should validate_presence_of :csv }

  it { should allow_mass_assignment_of :csv }
  it { should allow_mass_assignment_of :job_owner }
  it { should allow_mass_assignment_of :status }
  it { should have_attached_file :csv }

  ['text/csv', 'application/octet-stream',
   'text/comma-separated-values', 'application/csv', 'application/excel',
   'application/vnd.ms-excel', 'application/vnd.msexcel'].each do |content_type|
    it { should validate_attachment_content_type(:csv).allowing(content_type) }
  end

  it { should serialize(:csv_errors) }

  it "should order all async jobs by created at desc" do
    async_job1 = Fabricate(:draft_item_async_job)
    async_job2 = Fabricate(:user_async_job)

    AsyncJob.all.should == [async_job2, async_job1]
  end

  context "execute" do
    let!(:supplier_id) { 1 }
    let!(:async_job) { Fabricate(:draft_item_async_job) }
    let!(:open_file) { open("#{Rails.root}/public/system/#{async_job.csv.path}") }


    it "should create objects from csv" do
      async_job.should_receive(:open).with(async_job.csv.url).and_return(open_file)
      DraftItem.should_receive(:create_many_from_csv).with(open_file, supplier_id, {}).and_return(true)

      async_job.execute(supplier_id)
      async_job.reload.csv_errors.should == nil
      async_job.reload.status.should == AsyncJob::Status::SUCCESS
    end

    it "should add appropriate message for invalid file type" do
      async_job.should_receive(:open).with(async_job.csv.url).and_return(open_file)
      DraftItem.should_receive(:create_many_from_csv).and_raise(Exceptions::File::InvalidFileType)

      async_job.execute(supplier_id)
      async_job.reload.csv_errors[:message].should == App::Config.messages[:async_uploads][:invalid_file]
      async_job.status.should == AsyncJob::Status::FAILED
    end

    it "should add appropriate message for duplicate entry in csv" do
      async_job.should_receive(:open).with(async_job.csv.url).and_return(open_file)

      DraftItem.should_receive(:create_many_from_csv).and_raise(Exceptions::File::DuplicateEntityInCsv.new(1))

      async_job.execute(supplier_id)
      async_job.reload.csv_errors[:message].should == App::Config.messages[:async_uploads][:duplicate_record] % 1.to_s
      async_job.status.should == AsyncJob::Status::FAILED
    end

    it "should add errors for each row in csv" do
      class DummyError
        def full_messages
          "some error"
        end
      end
      async_job.should_receive(:open).with(async_job.csv.url).and_return(open_file)

      DraftItem.should_receive(:create_many_from_csv).and_raise(Exceptions::File::ErrorsInCsv.new({1 => DummyError.new, 2 => DummyError.new}))

      async_job.execute(supplier_id)
      async_job.reload.csv_errors.should == {1 => "some error", 2 => "some error"}
      async_job.status.should == AsyncJob::Status::FAILED
    end
  end
end
