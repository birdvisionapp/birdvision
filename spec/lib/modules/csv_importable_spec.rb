# encoding: UTF-8
require 'spec_helper'

describe CSVImportable do

  context "File Reading" do
    before :each do
      self.extend CSVImportable
    end

    let(:entity) { double("entity", :unique_attribute => nil) }
    it "should raise error if file does not exist" do
      expect { self.import_from_file("spec/nosuchdir/nosuchfile.csv", entity) }.to raise_error() #todo which error?
    end

    it "should raise error if invalid content type is provided" do
      expect { self.import_from_content(open("spec/fixtures/items.zip"), entity) }.to raise_error(Exceptions::File::InvalidFileType)
      expect { self.import_from_content(open("spec/fixtures/table.jpg"), entity) }.to raise_error(Exceptions::File::InvalidFileType)
    end
  end

  class FakeModel
    extend CSVImportable

    def headers
      %w(a b c)
    end
  end

  let(:csv_content) { "a,b,c\n1,2,3\n11,12,13\n" }
  let(:entity) { mock("entity") }
  let(:object1) { mock("object1") }
  let(:object2) { mock("object2") }

  context "CSV content validation" do

    it "should raise error if headers are wrong" do
      entity.should_receive(:headers).and_return(%w(x y))

      expect { FakeModel.import_from_content(csv_content, entity) }.to raise_error(Exceptions::File::InvalidCSVFormat)
    end

    it "should raise errors if unique attribute of an entity has duplicate values in the CSV" do
      csv_content = "a,b,c\n1,2,3\n1,3,4"
      entity.stub(:headers).and_return(%w(a b c))
      entity.stub(:unique_attribute).and_return('a')

      expect {
        FakeModel.import_from_content(csv_content, entity)
      }.to raise_error(Exceptions::File::DuplicateEntityInCsv)

    end

    it "should not raise errors if there are no duplicate values in the CSV" do
      csv_content = "a,b,c\n1,2,3\n10,3,4"
      entity.stub(:headers).and_return(%w(a b c))
      entity.stub(:unique_attribute).and_return('a')
      entity.stub(:batch_from_hash).and_return([object1])
      object1.stub(:valid?).and_return(true)
      object1.stub(:save)
      FakeModel.import_from_content(csv_content, entity).should_not raise_error(Exceptions::File::DuplicateEntityInCsv)
    end

    it "should not raise duplicate errors if there is no unique attribute for the entity" do
      csv_content = "a,b,c\n1,2,3\n1,3,4"
      entity.stub(:headers).and_return(%w(a b c))
      entity.stub(:unique_attribute).and_return(nil)
      entity.stub(:batch_from_hash).and_return([object1])
      object1.stub(:valid?).and_return(true)
      object1.stub(:save)
      FakeModel.import_from_content(csv_content, entity).should_not raise_error(Exceptions::File::DuplicateEntityInCsv)
    end


    it "should call save on model if proper csv passed" do
      entity.should_receive(:batch_from_hash).and_return([object1])
      entity.should_receive(:headers).and_return(%w(a b c))
      entity.stub(:unique_attribute).and_return('a')

      object1.stub(:valid?).and_return(true)
      object1.should_receive(:save)

      FakeModel.import_from_content(csv_content, entity)
    end

    it "should call save on model if csv with acceptable issues is provided" do
      content_with_acceptable_issues = "a,b,c\n\n\n1,2,3\n\n\n3,2,1,4"
      entity.should_receive(:batch_from_hash).and_return([object1, object2])
      entity.should_receive(:headers).and_return(%w(a b c))
      entity.stub(:unique_attribute).and_return('a')

      object1.stub(:valid?).and_return(true)
      object1.should_receive(:save)
      object2.stub(:valid?).and_return(true)
      object2.should_receive(:save)

      FakeModel.import_from_content(content_with_acceptable_issues, entity)
    end

    it "should raise exception if contents of csv are not valid" do
      entity.should_receive(:batch_from_hash).and_return([object1, object2])
      entity.should_receive(:headers).and_return(%w(a b c))
      entity.stub(:unique_attribute).and_return('a')

      object1.stub(:valid?).and_return(true)
      object1.should_receive(:save).never
      object2.stub(:valid?).and_return(false)
      object2.should_receive(:errors)
      object2.should_receive(:save).never
      object2.stub(:a).and_return("a_id")

      begin
        FakeModel.import_from_content(csv_content, entity)
        fail "Expected exception"
      rescue Exceptions::File::ErrorsInCsv => e
        e.data.should_not include(0)
        e.data.should include(1)
      end
    end
  end

  context "block" do
    let(:csv_content) { "a,b,c\n  1 ,2,  3\n11,12,13\n" }
    let(:csv_fake_model) { double("csv fake model", :unique_attribute => nil) }
    before(:each) do
      csv_fake_model.should_receive(:headers).and_return(%w(a b c))
      object1.stub(:valid?).and_return(true)
      object2.stub(:valid?).and_return(true)
    end
    it "should call the passed block with the attribute hash that is created from csv row" do
      csv_fake_model.should_receive(:batch_from_hash).with([{"a" => "1", "b" => "2", "c" => "3"}, {"a" => "11", "b" => "12", "c" => "13"}]).and_return([object1, object2])

      object1.should_receive(:save)
      object2.should_receive(:save)

      FakeModel.import_from_content(csv_content, csv_fake_model)
    end
  end
end