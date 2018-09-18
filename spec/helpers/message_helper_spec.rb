require 'spec_helper'

describe MessageHelper do
  context "alert if" do
    it "should show message given condition evaluates to true" do
      message = "hello"
      text = alert_if(true, message)

      text.should == "<div>#{message}</div>"
    end
    it "should not show message given condition evaluates to false" do
      message = "hello"
      text = alert_if(false, message)

      text.should be_nil
    end
    it "should not show message given message is not present" do
      text = alert_if(true, nil)

      text.should be_nil
    end

    it "should generate list for list of messages" do
      text = alert_if(true, %w(a b))

      message = "<ul><li>a</li><li>b</li></ul>"
      text.should == "<div>#{message}</div>"
    end

    it "should tweak css class" do
      message = "hello"
      text = alert_if(true, message, :class => %w(alert-success))

      text.should == "<div class=\"alert-success\">#{message}</div>"
    end

    it "should escape html" do
      message = "<div>"
      text = alert_if(true, message)

      text.should == "<div>&lt;div&gt;</div>"
    end
  end
end