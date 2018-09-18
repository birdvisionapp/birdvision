require 'spec_helper'

describe Slab do
  it { should allow_mass_assignment_of :payout_percentage }
  it { should allow_mass_assignment_of :lower_limit }
  it { should allow_mass_assignment_of :client_reseller }

  it { should validate_numericality_of(:lower_limit).with_message("Sales details must be a number") }
  it { should validate_presence_of(:lower_limit).with_message("Please enter sales details") }

  it { should validate_numericality_of(:payout_percentage).with_message("Payout percentage must be a number") }
  it { should validate_presence_of(:payout_percentage).with_message("Please enter payout percentage") }

  it { should be_trailed }
end