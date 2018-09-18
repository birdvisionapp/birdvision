require 'request_spec_helper'
describe "Pre Deploy Task Spec" do

  context "pre deploy check", :pre_deploy_check => true do
    it "verify environment variables" do

      out = `bundle exec rake production heroku:config`.gsub("\n\n", "")
      p "output of bundle exec rake production heroku:config", out

      expected_configs = %w(DATABASE_URL CLEARDB_DATABASE_URL
                            SENDGRID_USERNAME SENDGRID_PASSWORD MAILER_HOST
                            RACK_ENV
                            AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_BUCKET
                            FOG_DIRECTORY FOG_PROVIDER FOG_REGION)
      hash = {}

      out.each_line do |line|
        hash.merge! Hash[*line.split(":", 2)]
      end

      expected_configs.each do |config|
        p "======== checking #{config} value [#{hash[config]}] ========="
        hash[config].should_not be_nil
      end

    end
  end
end

