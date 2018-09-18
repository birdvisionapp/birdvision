require 'spec_helper'

describe StaticPagesController do
  it "routes" do
    {:get => privacy_policy_path}.should route_to("static_pages#privacy_policy")
    {:get => faq_path}.should route_to("static_pages#faq")
    {:get => terms_and_conditions_path}.should route_to("static_pages#terms_and_conditions")
    {:get => contact_us_path}.should route_to("static_pages#contact_us")
  end

  it "should render static pages for logged in user " do
    sign_in Fabricate(:user)
    [:privacy_policy, :faq, :terms_and_conditions, :contact_us].each do |static_page|
      get static_page
      assigns[:hide_search].should == true
      response.should be_ok
      response.should render_template(:static_page)
    end
  end
  it "should render static pages for non logged in user " do
    [:privacy_policy, :faq, :terms_and_conditions, :contact_us].each do |static_page|
      get static_page
      assigns[:hide_search].should == true
      response.should be_ok
      response.should render_template(:static_page)
    end
  end

  it "should display a success message for submitting contact us form with all valid values" do
    post :contact_request, "contact_name" => "Gabbar Singh", "contact_email" => "gabbar@sholay.com",
                            "contact_message" => "Ye Reward Mujhe de de"
    response.should render_template(:contact_us)
    assigns[:type].should == :notice
    assigns[:message].should == "Your message has been sent to our Customer Care Team."
  end
  it "should display a failure message for submitting contact us form with invalid values" do
    post :contact_request, "contact_name" => "", "contact_email" => "gabbar@sholay.com",
                            "contact_message" => ""
    response.should render_template(:contact_us)
    assigns[:type].should == :alert
    assigns[:message].should == "Please fill all fields."
  end
  it "should send email for submitting contact us form" do
    mailer = mock("contact_us_mailer")
    mailer.should_receive(:send_mail).with(instance_of(Hash)).and_return(mailer)

    ContactUsMailer.stub(:delay).and_return mailer

    post :contact_request, "contact_name" => "Gabbar Singh", "contact_email" => "gabbar@sholay.com",
                            "contact_message" => "Ye Reward Mujhe de de"
  end
end