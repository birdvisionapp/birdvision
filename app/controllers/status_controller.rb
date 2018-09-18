class StatusController < ApplicationController

  def index
    service_checks = filter_service_checks(params[:only])
    service_status = Hash[service_checks.collect { |k, block| [k, block.call] }]
    render :json => service_status
  end

  private

  def check_email
    check_safely {
      Net::SMTP.start(ActionMailer::Base.smtp_settings[:address], ActionMailer::Base.smtp_settings[:port]) {}
      true
    }
  end

  def check_search
    check_safely {
      response = HTTParty.get("#{Sunspot.config.solr.url}/ping")
      response.code == 200
    }
  end

  def check_sms
    check_safely {
      response = HTTParty.get("https://twilix.exotel.in/v1/Accounts/#{Exotel.exotel_sid}/", :basic_auth => {:username => Exotel.exotel_sid, :password => Exotel.exotel_token})
      response.code == 200
    }
  end

  def check_jobs
    max_age = (params[:jobs_max_age] || 15).to_i.minutes
    Delayed::Job.where('created_at < ?', Time.now - max_age).count == 0
  end

  def check_db
    ActiveRecord::Base.connected?
  end

  def filter_service_checks(only=nil)
    services = {
        "email" => lambda { check_email },
        "db" => lambda { check_db },
        "search" => lambda { check_search },
        "jobs" => lambda { check_jobs },
        "sms" => lambda { check_sms }
    }
    only.nil? ? services : services.slice(only)
  end

  def check_safely
    begin
      return yield
    rescue StandardError
      return false
    end
  end
end