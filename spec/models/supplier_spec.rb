require 'spec_helper'

describe Supplier do
  it { should allow_mass_assignment_of :name }
  it { should allow_mass_assignment_of :phone_number  }
  it { should allow_mass_assignment_of :address }
  it { should allow_mass_assignment_of :geographic_reach}
  it { should allow_mass_assignment_of :supplied_categories }
  it { should allow_mass_assignment_of :description }
  it { should allow_mass_assignment_of :additional_notes }
  it { should allow_mass_assignment_of :delivery_time }
  it { should allow_mass_assignment_of :payment_terms }

  it { should validate_uniqueness_of :name }
  it { should validate_presence_of :name }
  it { should validate_presence_of :payment_terms }
  it { should validate_presence_of :delivery_time }
  it { should validate_presence_of :geographic_reach }
  it { should be_trailed }

end
