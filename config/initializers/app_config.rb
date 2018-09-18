require File.expand_path('../ext/hash.rb', __FILE__)

module App
  class Config
    def self.load(filename)
      data = YAML.load(ERB.new(File.new(filename).read).result).recursively_symbolize_keys!
      key = data[Rails.env.to_sym] ? data[Rails.env.to_sym].keys.first : data.keys.first
      values = data[Rails.env.to_sym] ? data[Rails.env.to_sym].values.first : data.values.first
      class_variable_set("@@#{key}", values)
      cattr_reader(key.to_sym)
    end
  end
end
