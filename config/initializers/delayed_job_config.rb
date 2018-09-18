Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 2
Delayed::Worker.max_run_time = 42.hours
Delayed::Worker.read_ahead = 10
Delayed::Worker.delay_jobs = Rails.application.config.enable_delayed_jobs