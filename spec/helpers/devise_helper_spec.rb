require 'spec_helper'

class DeviceHelperUser
  include DeviseHelper

  def initialize(resource)
    @resource = resource
  end

  def resource
    @resource
  end

  def content_tag( symbol, text)
    text
  end
end

class Resource
end

describe DeviseHelper do

  it "should display errors when resources errors are NOT empty" do
    resource = Resource.new
    resource.stub_chain(:errors, :empty?).and_return(false)
    resource.stub_chain(:errors, :full_messages).and_return(%w(abc def))
    devise_error_messages = DeviceHelperUser.new(resource).devise_error_messages!

    devise_error_messages.should include("abc")
    devise_error_messages.should include("def")
    devise_error_messages.should have_selector("div#errors")

  end

  it "should NOT display errors when errors are empty" do
    resource = Resource.new
    resource.stub_chain(:errors, :empty?).and_return(true)
    DeviceHelperUser.new(resource).devise_error_messages!.should be_empty
  end

end

