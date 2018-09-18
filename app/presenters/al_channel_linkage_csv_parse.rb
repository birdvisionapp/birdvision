class AlChannelLinkageCsvParse

  def self.add_al_linkage(retailer_code, ro_code, dealer_codes)
    dealer_codes = dealer_codes.gsub(/\s+/, "").split(',')
    check_for_user = User.where(:participant_id => retailer_code, :client_id => ENV['AL_CLIENT_ID'].to_i).first
    AlChannelLinkage.where(:retailer_code => retailer_code).delete_all
    dealer_codes.each do |code|
      # al_channel_linkage = AlChannelLinkage.find_or_initialize_by_retailer_code_and_ro_code_and_dealer_code(retailer_code, ro_code, code)
      al_channel_linkage = AlChannelLinkage.create(:retailer_code => retailer_code,:ro_code => ro_code, :dealer_code => code)
      unless check_for_user.nil?
        al_channel_linkage.user_id = check_for_user.id  
      end
      al_channel_linkage.save!
    end

  end

end