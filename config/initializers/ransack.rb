Ransack.configure do |config|
  config.add_predicate 'date_lteq',
    :arel_predicate => 'lteq',
    :formatter => proc {|v| v.to_date.to_time.end_of_day },
    :validator => proc {|v| v.present? },
    :compounds => true,
    :type => :date
  config.add_predicate 'date_gteq',
    :arel_predicate => 'gteq',
    :formatter => proc {|v| v.to_date.to_time.beginning_of_day },
    :validator => proc {|v| v.present? },
    :compounds => true,
    :type => :date
  config.add_predicate 'start_gteq',
    :arel_predicate => 'gteq',
    :formatter => proc {|v| v.to_date },
    :validator => proc {|v| v.present? },
    :compounds => true,
    :type => :date
  config.add_predicate 'end_lteq',
    :arel_predicate => 'lteq',
    :formatter => proc {|v| v.to_date },
    :validator => proc {|v| v.present? },
    :compounds => true,
    :type => :date
end