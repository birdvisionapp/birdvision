require 'spec_helper'

describe Admin::UsersController do
  login_admin

  context "Browse" do

    it "should show all users sorted by updated at" do
      user1 = Fabricate(:user, :participant_id => 1, :updated_at => Date.yesterday - 10.days, :created_at => Date.yesterday - 11.days)
      user2 = Fabricate(:user, :participant_id => 2, :updated_at => Date.yesterday - 5.days, :created_at => Date.yesterday - 20.days)

      get :index
      assigns[:users_stats].should == {"Activated" => 2}
      assigns[:users].should == [user2, user1]
      response.should be_success
    end

    it "should show all user stats" do
      user1 = Fabricate(:user, :participant_id => 1, :activation_status => User::ActivationStatus::ACTIVATED)
      user2 = Fabricate(:user, :participant_id => 2, :activation_status => User::ActivationStatus::LINK_NOT_SENT)
      user3 = Fabricate(:user, :participant_id => 3, :activation_status => User::ActivationStatus::NOT_ACTIVATED)

      get :index
      assigns[:users_stats].should == {"Activated" => 1, "Link Not Sent" => 1, "Not Activated" => 1}
      assigns[:users].should == [user3, user2, user1]
      response.should be_success
    end


    context "filter by created at" do
      before :each do
        emerson = Fabricate(:client, :client_name => "Emerson")
        @samba = Fabricate(:user, :full_name => "samba", :participant_id => 1, :created_at => Date.yesterday, :client => emerson)
        @jay = Fabricate(:user, :full_name => "Jay", :participant_id => 2, :created_at => Date.today, :client => emerson)
        @gabbar = Fabricate(:user, :full_name => "gabbar", :participant_id => 3, :created_at => Time.now, :client => emerson)
        @viru = Fabricate(:user, :full_name => "Viru", :participant_id => 4, :created_at => Date.tomorrow, :client => emerson)
      end

      it "should filter from start of day when created_at_date_gteq field is given" do
        get :index, :q => {:created_at_date_gteq => Date.today.strftime("%d-%m-%Y")}
        users = assigns[:users]
        users.length.should == 3
        users.should include(@viru, @jay, @gabbar)
      end

      it "should filter before end of day when created_at_date_lteq field is given" do
        get :index, :q => {:created_at_date_lteq => Date.today.strftime("%d-%m-%Y")}
        users = assigns[:users]
        users.length.should == 3
        users.should include(@samba, @jay, @gabbar)
      end

      it "should filter between start of day and end of day when created_at_date_gteq,created_at_date_lteq even when fields are same" do
        get :index, :q => {:created_at_date_gteq => Date.today.strftime("%d-%m-%Y"), :created_at_date_lteq => Date.today.strftime("%d-%m-%Y")}
        users = assigns[:users]
        users.length.should == 2
        users.should include(@jay, @gabbar)
      end
    end

    it "should render import users page" do
      get :import_csv
      response.should be_success
      response.should render_template(:import_csv)
    end

  end

  context "Bulk Upload" do
    before :each do
      @scheme = Fabricate(:scheme, :levels => %w(level1), :clubs => %w(club1))
    end

    it "should not create users if scheme is not selected" do

      post :upload_csv, "csv" => Rack::Test::UploadedFile.new("spec/fixtures/upload_users_with_single_level_club.csv", "text/csv")
      User.count.should == 0
      flash[:alert].should == "Please select the Scheme for these Participants from the dropdown menu"
      response.should redirect_to import_csv_admin_users_path
    end

    it "should show error if csv is not selected" do

      post :upload_csv
      User.count.should == 0
      flash[:alert].should == "Please choose a file"
      response.should redirect_to import_csv_admin_users_path
    end

    it "should create users in bulk" do
      async_job_mock = mock("async_job_mock")
      delayed_mock = mock("delayed_job_mock")

      csv = Rack::Test::UploadedFile.new("spec/fixtures/upload_users_with_single_level_club.csv", "text/csv")

      AsyncJob.should_receive(:create).with(:job_owner => "User", :csv => csv, :status => AsyncJob::Status::PROCESSING).and_return(async_job_mock)

      async_job_mock.should_receive(:valid?).and_return(true)
      async_job_mock.should_receive(:delay).and_return(delayed_mock)
      delayed_mock.should_receive(:execute).with(@scheme.id.to_s, {:add_points => false})

      post :upload_csv, "csv" => csv, "scheme" => @scheme, "replace_points" => "Replace points"

      flash[:notice].should == "File has successfully been scheduled for upload, please check the upload tab after a while."

      response.should redirect_to admin_uploads_index_path
    end

    it "should not create users if csv is of incorrect format" do
      async_job_mock = mock("async_job_mock")
      delayed_mock = mock("delayed_job_mock")

      csv = Rack::Test::UploadedFile.new("spec/fixtures/favicon.ico")

      AsyncJob.should_receive(:create).with(:job_owner => "User", :csv => csv, :status => AsyncJob::Status::PROCESSING).and_return(async_job_mock)

      async_job_mock.should_receive(:valid?)
      async_job_mock.should_receive(:delay).never
      delayed_mock.should_receive(:execute).never

      post :upload_csv, "csv" => csv, "scheme" => @scheme

      flash[:alert].should == "Please use a CSV file in the template provided to upload/update Participants"

      response.should redirect_to import_csv_admin_users_path

    end
  end

  context "Batch actions" do
    before :each do
      @scheme = Fabricate(:scheme)
    end

    it "should not send activation email if user not selected " do
      user = Fabricate(:user, :participant_id => 1)
      Fabricate(:user_scheme, :user => user, :scheme => @scheme)

      post :send_activation_email_to, send_activation_link: true

      flash[:alert].should == "Please select at least one Participant to Send Activation Link"
      response.should redirect_to admin_users_path
    end

    it "should send activation email to all " do
      user1 = Fabricate(:user, :participant_id => 1)
      user2 = Fabricate(:user, :participant_id => 2)

      Fabricate(:user_scheme, :user => user1, :scheme => @scheme)
      Fabricate(:user_scheme, :user => user2, :scheme => @scheme)

      post :send_activation_email_to, send_activation_link: true, user_ids: [user1.id, user2.id]
      flash[:notice].should == "2 activation link(s) have been sent successfully"
      response.should redirect_to admin_users_path
    end

    it "should not change status to inactive if participant not selected " do
      user = Fabricate(:user, :participant_id => 1)
      Fabricate(:user_scheme, :user => user, :scheme => @scheme)

      post :send_activation_email_to, inactive: true

      flash[:alert].should == "Please select at least one Participant to Inactivate"
      response.should redirect_to admin_users_path
    end

    it "should change status inactive to all participants" do
      user1 = Fabricate(:user, :participant_id => 1)
      user2 = Fabricate(:user, :participant_id => 2)

      Fabricate(:user_scheme, :user => user1, :scheme => @scheme)
      Fabricate(:user_scheme, :user => user2, :scheme => @scheme)

      post :send_activation_email_to, inactive: true, user_ids: [user1.id, user2.id]
      flash[:notice].should == "2 participant(s) have been Inactivated successfully"
      response.should redirect_to admin_users_path
    end


    it "should not change status to active if participant not selected " do
      user = Fabricate(:user, :participant_id => 1)
      Fabricate(:user_scheme, :user => user, :scheme => @scheme)

      post :send_activation_email_to, active: true

      flash[:alert].should == "Please select at least one Participant to Activate"
      response.should redirect_to admin_users_path
    end

    it "should change status inactive to all participants" do
      user1 = Fabricate(:user, :participant_id => 1)
      user2 = Fabricate(:user, :participant_id => 2)

      Fabricate(:user_scheme, :user => user1, :scheme => @scheme)
      Fabricate(:user_scheme, :user => user2, :scheme => @scheme)

      post :send_activation_email_to, active: true, user_ids: [user1.id, user2.id]
      flash[:notice].should == "2 participant(s) have been Activated successfully"
      response.should redirect_to admin_users_path
    end
  end

  context "download csv" do

    it "should download csv for filtered results" do
      user1 = Fabricate(:user, :full_name => "romeo")
      user2 = Fabricate(:user, :full_name => "juliet")

      get :index, :q => {:full_name_cont => user1.full_name}, :format => :csv

      response.should be_success
      response.body.lines.count.should == 2
      response.body.should include "romeo"
      response.body.should_not include "juliet"
    end

    it "should group user schemes and show only distinct user even when empty scheme_id in filter is applied" do
      client = Fabricate(:client)
      romeo = Fabricate(:user, :full_name => "romeo", :client => client)
      Fabricate(:user_scheme, :user => romeo, :scheme => Fabricate(:scheme, :name => "sbd", :client => client))
      Fabricate(:user_scheme, :user => romeo, :scheme => Fabricate(:scheme, :name => "bbd", :client => client))

      Fabricate(:user, :full_name => "juliet")

      # there's weird behavior ransack is showing, if we dont pass empty `user_schemes_scheme_id_eq`
      # then it fetches distinct records. if we pass it empty, then we should explicitly pass (:distinct => true)
      # to make sure the bug in controller is fixed, we need to pass this.
      get :index, :q => {:user_schemes_scheme_id_eq => ""}, :format => :csv

      response.should be_success
      response.body.lines.count.should == 3
      response.body.should include "romeo"
      response.body.should include "bbd"
      response.body.should include "sbd"
      response.body.should include "juliet"
    end
  end

end