require 'spec_helper'

describe ClientCatalog do
  it {should have_one(:client)}
  it {should have_many(:client_items)}
  it { should be_trailed }
end