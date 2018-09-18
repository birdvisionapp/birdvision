require 'spec_helper'

describe LessThanEqualToValidator do
  context 'validation on less than' do
    let(:validator) { LessThanEqualToValidator.new({:attributes => {}, :attribute => :end_date}) }

    before(:each) do
      @mock = mock("a")
      @errors = mock("errors")
      @mock.stub_chain(:class, :human_attribute_name).and_return("End date")
      @mock.stub(:errors).and_return(@errors)
    end

    it "should validate that specified attribute is less than option" do
      @mock.should_receive(:end_date).and_return(Date.today + 2.days)
      @errors.should_receive(:add).never

      validator.validate_each(@mock, :start_date, Date.today)
    end

    it "should validate that no error is raised if specified attribute is nil" do
      @mock.should_receive(:end_date).and_return(Date.today - 2.days)
      @errors.should_receive(:add).never

      validator.validate_each(@mock, :start_date, nil)
    end

    it "should validate that no error is raised if option attribute is nil" do
      @mock.should_receive(:end_date).and_return(nil)
      @errors.should_receive(:add).never

      validator.validate_each(@mock, :start_date, Date.today)
    end

    it "should indicate error if specified attribute is greater than option" do
      @mock.should_receive(:end_date).and_return(Date.today - 2.days)
      @errors.should_receive(:add).with(:start_date, :less_than_equal_to_other, hash_including(:other => 'End date'))

      validator.validate_each(@mock, :start_date, Date.today)
    end
  end
  context "validation on less than equal to" do
    let(:less_than_equal_validator) { LessThanEqualToValidator.new({:attributes => {}, :attribute => :total_points, :allow_equal => true }) }

    before(:each) do
      @mock = mock("a")
      @errors = mock("errors")
      @mock.stub_chain(:class, :human_attribute_name).and_return("Redeemed points")
      @mock.stub(:errors).and_return(@errors)
    end

    it "should return true if specified attribute is equal to option" do
      @mock.should_receive(:total_points).and_return(10000)
      @errors.should_receive(:add).never

      less_than_equal_validator.validate_each(@mock, :redeemed_points, 10000)
    end
  end
end