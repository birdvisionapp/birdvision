RSpec::Matchers.define :be_trailed do
  match do |actual|
    actual.should respond_to(:versions)
  end
end