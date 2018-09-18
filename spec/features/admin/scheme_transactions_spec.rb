require 'request_spec_helper'

feature "Admin - Points Statement Page" do
  before :each do
    admin_user = Fabricate(:admin_user)
    login_as admin_user, :scope => :admin_user
  end

  scenario "Should render Scheme Transactions Page" do
    visit(admin_scheme_transactions_path)
    within("h1") do
      page.should have_content "Points Statement"
    end

    within("#mainNavigation") do
      page.find("a.active").should have_content("Points Statement")
    end
  end

  scenario "Should have uploaded and redeemed points information" do
    client = Fabricate(:client, :code => 'cc1')
    scheme1 = Fabricate(:scheme, :name => 'TestScheme', :client => client)
    Fabricate(:scheme_transaction, :client => client, :scheme => scheme1, :transaction => Fabricate.build(:user_scheme, :scheme => scheme1, :total_points => 10_000))
    visit(admin_scheme_transactions_path)
    within(".users_stats") do
      page.should have_content("Uploaded Points: 10,000")
      page.should have_content("Redeemed Points: 0")
    end
  end

  scenario "Should display all points transactions" do
    client = Fabricate(:client, :code => 'cc1')
    scheme1 = Fabricate(:scheme, :name => 'TestScheme', :client => client)
    transaction = Fabricate(:scheme_transaction, :client => client, :scheme => scheme1, :transaction => Fabricate.build(:user_scheme, :scheme => scheme1, :total_points => 10_000, :redeemed_points => 5_000))
    visit(admin_scheme_transactions_path)
    within(".scheme-transactions") do
      ["Date", "Client", "Scheme", "Full Name", "Username", "Description", "Credit", "Debit", "Balance"].each { |header|
        page.should have_content(header)
      }
      page.should have_content(transaction.client.client_name)
      page.should have_content(transaction.scheme.name)
      page.should have_content(transaction.user.full_name)
      page.should have_content(transaction.user.username)
      page.should have_content("10,000")
      page.should have_content("5,000")
    end
    within(".actions") do
      page.should have_link('Download', {:href => admin_scheme_transactions_path(:format => "csv")})
    end
    click_on 'Download'
    page.body.lines.count.should == 3
  end

end