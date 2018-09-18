require 'spec_helper'

describe MailUrlHelper do
  helper MailUrlHelper
  let(:client_with_domain) { Fabricate(:client, :domain_name => "axis.bvc.com") }
  let(:client_without_domain) { Fabricate(:client, :domain_name => nil) }
  let(:user_with_domain) { Fabricate(:user, :client => client_with_domain) }
  let(:user_without_domain) { Fabricate(:user, :client => client_without_domain) }

  context "client specific url" do
    context "root_url" do
      it "should return with correct domain_name given client with domain_name" do
        root_url_for(user_with_domain).should == "http://axis.bvc.com/"
      end
      it "should return root url with no domain_name if client doesn't have the domain_name specified" do
        root_url_for(user_without_domain).should == "http://test.host/"
      end
    end

    context "edit password url" do
      it "should return with correct domain_name given client with domain_name" do
        edit_password_path_for(user_with_domain).should == "http://axis.bvc.com/users/password/edit?mode=activate"
      end
      it "should return without domain_name given client without domain_name" do
        edit_password_path_for(user_without_domain).should == "http://test.host/users/password/edit?mode=activate"
      end
    end

    context "order_url" do
      it "should return with correct domain_name given client with domain_name" do
        order = Fabricate(:order, :user => user_with_domain)
        order_item = Fabricate(:order_item, :order => order)
        order_url_for(user_with_domain, order_item).should == "http://axis.bvc.com/schemes/scheme/orders/1"
      end
      it "should return without domain_name given client without domain_name" do
        order = Fabricate(:order, :user => user_without_domain)
        order_item = Fabricate(:order_item, :order => order)
        order_url_for(user_without_domain, order_item).should == "http://test.host/schemes/scheme/orders/1"
      end
    end

    context "orders url" do
      it "should return with correct domain_name given client with domain_name" do
        orders_link_for(user_with_domain).should == "http://axis.bvc.com/orders"
      end
      it "should return without domain_name given client without domain_name" do
        orders_link_for(user_without_domain).should == "http://test.host/orders"
      end
    end

    context "contact us url" do
      it "should return with correct domain_name given client with domain_name" do
        contact_us_url_for(user_with_domain).should == "http://axis.bvc.com/contact_us"
      end
      it "should return without domain_name given client without domain_name" do
        contact_us_url_for(user_without_domain).should == "http://test.host/contact_us"
      end
    end

    context "add_client_host" do
      it "should add host given client with domain_name" do
        add_client_host(user_with_domain, {}).should include(:host => 'axis.bvc.com')
      end
      it "should return without domain_name given client without domain_name" do
        add_client_host(user_without_domain, {}).should_not include(:host)
      end
    end
  end
end