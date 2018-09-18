require 'spec_helper'

describe Admin::SchemesController do
  context "routes" do
    it "should route requests correctly" do
      {:get => admin_schemes_path}.should route_to('admin/schemes#index')
      {:get => admin_scheme_download_report_path(:scheme_id => 1)}.should route_to('admin/schemes#download_report', :scheme_id => '1')
      {:get => admin_scheme_csv_template_path(:scheme_id => 1)}.should route_to('admin/schemes#csv_template', :scheme_id => "1")
    end
  end

  login_admin

  context "list" do
    it "should show list of all schemes sorted by creation time" do
      scheme1 = Fabricate(:scheme)
      scheme2 = Fabricate(:scheme)

      get :index

      assigns[:schemes].should == [scheme2, scheme1]
      response.should be_ok
    end
  end

  context "csv" do
    let(:test_client) { Fabricate(:client, :client_name => "Emerson", :points_to_rupee_ratio => 2) }
    let(:big_bang_dhamaka) { Fabricate(:scheme, :client => test_client, :name => "BBD", :redemption_start_date => Date.yesterday, :redemption_end_date => Date.today + 45.days) }

    it "should download csv" do
      user1 = Fabricate(:user, :participant_id => "U1", :client => test_client, :activation_status => User::ActivationStatus::ACTIVATED, :activated_at => DateTime.new(2010, 12, 23))
      user2 = Fabricate(:user, :participant_id => "U2", :client => test_client, :activation_status => User::ActivationStatus::ACTIVATED, :activated_at => DateTime.new(2010, 12, 23))
      Fabricate(:user_scheme, :scheme => big_bang_dhamaka, :user => user1, :total_points => 500, :redeemed_points => 200)
      Fabricate(:user_scheme, :scheme => big_bang_dhamaka, :user => user2, :total_points => 2000, :redeemed_points => 300)

      get :download_report, :scheme_id => big_bang_dhamaka.id, :format => :csv

      response.should be_success
      response.body.lines.count.should == 3
      response.body.should include test_client.client_name
      response.body.should include big_bang_dhamaka.name
      response.body.should include user1.participant_id
      response.body.should include user2.participant_id
    end

    it "should download csv template" do
      CsvUser.stub_chain(:new, :template).and_return("col1,col2")
      get :csv_template, :scheme_id => big_bang_dhamaka.id, :format => :csv

      response.should be_ok
      response.body.should == "col1,col2"
    end
  end
end