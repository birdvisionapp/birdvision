require 'spec_helper'

describe App::Config do

  it "should read errors from errors YAML file" do
    App::Config.errors[:cart][:cart_item][:invalid_quantity].should_not be_nil
  end

end