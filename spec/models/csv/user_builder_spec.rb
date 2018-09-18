require 'spec_helper'

describe Csv::UserBuilder do
  let(:client) { Fabricate.build(:client) }
  it "should create new user with given attributes" do
    attrs = {:participant_id => '123', :full_name => 'Bob'}.stringify_keys

    user = Csv::UserBuilder.new(client, nil, attrs).build

    user.full_name.should == 'Bob'
    user.client.should == client
  end
  it "should update existing user with given attributes" do
    attrs = {:participant_id => '123', :full_name => 'Bob'}.stringify_keys

    existing_user = Fabricate.build(:user, :participant_id => '123', :full_name => 'Bob old', :client => client)
    user = Csv::UserBuilder.new(client, existing_user, attrs).build

    user.full_name.should == 'Bob'
    user.client.should == client
  end
  it "should ignore inapplicable attributes" do
    attrs = {:participant_id => '123', :full_name => 'Bob', :garbage => 'attribute'}.stringify_keys

    expect { Csv::UserBuilder.new(client, nil, attrs).build }.to_not raise_error
  end
end