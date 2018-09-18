require 'spec_helper'
require "cancan/matchers"

describe Ability do
  context "Super Admin User" do
    let(:admin_user) { Fabricate(:admin_user) }
    let!(:ability) { Ability.new(admin_user) }
    subject { ability }

    it { should be_able_to(:manage, :all) }
    it { should_not be_able_to(:view, :reseller_dashboard) }
    it { should  be_able_to(:view, :activation_link) }
  end

  context "Reseller" do
    let(:admin_user) { Fabricate(:reseller_admin_user) }
    let!(:ability) { Ability.new(admin_user) }
    subject { ability }

    it { should be_able_to(:view, :reseller_dashboard) }
    it { should_not be_able_to(:view, :admin_dashboard) }
    it { should_not be_able_to(:manage, :all) }
  end

  context "Client Manager" do
    let!(:other_client) { Fabricate(:client) }
    let!(:managers_client) { Fabricate(:client) }
    let!(:client_manager) { Fabricate(:client_manager, :client => managers_client) }

    let!(:scheme) { Fabricate(:scheme, :client => managers_client) }
    let!(:another_scheme) { Fabricate(:scheme, :client => other_client) }

    let!(:user) { Fabricate(:user, :client => managers_client) }
    let!(:another_user) { Fabricate(:user, :client => other_client) }

    let!(:user_scheme) { Fabricate(:user_scheme, :user => user, :scheme => scheme) }
    let!(:other_user_scheme) { Fabricate(:user_scheme, :user => user, :scheme => another_scheme) }

    let!(:level_club) { Fabricate(:level_club, :scheme => scheme) }
    let!(:other_level_club) { Fabricate(:level_club, :scheme => another_scheme) }
    let!(:admin_user) { client_manager.admin_user }
    let!(:ability) { Ability.new(admin_user) }

    let!(:scheme_transaction) { Fabricate(:scheme_transaction, :client => managers_client) }
    let!(:another_scheme_transaction) { Fabricate(:scheme_transaction, :client => other_client) }

    subject { ability }

    it { should be_able_to(:view, :admin_dashboard) }
    it { should_not be_able_to(:view, :activation_link) }
    it { should be_able_to(:read, managers_client) }
    it { should_not be_able_to(:read, other_client) }

    it { should be_able_to(:read, scheme) }
    it { should_not be_able_to(:read, another_scheme) }

    it { should be_able_to(:read, user) }
    it { should_not be_able_to(:manage, another_user) }

    it { should be_able_to(:read, user_scheme) }
    it { should_not be_able_to(:read, other_user_scheme) }

    it { should be_able_to(:read, managers_client.client_catalog) }
    it { should_not be_able_to(:read, other_client.client_catalog) }

    it { should be_able_to(:read, level_club) }
    it { should_not be_able_to(:read, other_level_club) }

    it "should be able to read only info pertaining to its client's catalog" do
      should be_able_to(:read, Fabricate(:catalog_item, :client_item => Fabricate(:client_item, :client_catalog => managers_client.client_catalog)))
      should_not be_able_to(:read, Fabricate(:catalog_item, :client_item => Fabricate(:client_item, :client_catalog => other_client.client_catalog)))
    end

    it { should_not be_able_to(:view, :reseller_info) }
    it { should_not be_able_to(:view, :bvc_monetary_fields) }

    it { should be_able_to(:read, scheme_transaction) }
    it { should_not be_able_to(:read, another_scheme_transaction) }

  end

  context "Any Other Role" do
    it "should not be able to do anything" do
      user = Fabricate(:admin_user, :role => "some idiot")
      ability = Ability.new(user)
      ability.should_not be_able_to(:manage, :all)
    end
  end

end