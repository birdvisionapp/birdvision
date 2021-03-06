class AccessGrant < ActiveRecord::Base

  ACCESS_KEY_LENGTH = 16
  
  attr_accessible :access_token, :access_token_expires_at, :client_id, :code, :refresh_token, :state, :user_id

  # Associations
  belongs_to :user
  belongs_to :client
  before_create :generate_tokens

  def self.prune!
    delete_all(["created_at < ?", 3.days.ago])
  end

  def self.authenticate(code, client_id)
    AccessGrant.where("code = ? AND client_id = ?", code, client_id).first
  end

  def generate_tokens
    [:code, :access_token, :refresh_token].each do |column|
      begin
        self[column] = SecureRandom.hex(ACCESS_KEY_LENGTH)
      end while AccessGrant.exists?(column => self[column])
    end
  end

  def redirect_uri_for(redirect_uri)
    if redirect_uri =~ /\?/
      redirect_uri + "&code=#{code}&response_type=code&state=#{state}"
    else
      redirect_uri + "?code=#{code}&response_type=code&state=#{state}"
    end
  end

  # Note: This is currently configured through devise, and matches the AuthController access token life
  def start_expiry_period!
    self.update_attribute(:access_token_expires_at, Time.now + Devise.timeout_in)
  end

end
