class CsvUser

  def initialize(scheme, add_points = true, role_id = nil)
    @scheme = scheme
    @client = scheme.client
    @add_points = add_points
    @role_id = role_id
  end

  def headers
    common_headers = %w(participant_id full_name email mobile_number landline_number address pincode points notes status
     region representative_id current_achievements) + club_target_names
    @scheme.is_1x1? ? common_headers : common_headers + %w(level club)
  end

  def from_hash(attr_hash, existing_users)
    attr_hash.keep_if { |key, value| value.present? && headers.include?(key) }
    user = Csv::UserBuilder.new(@client, existing_users[participant_id(attr_hash)], attr_hash).build
    user.user_role_id = @role_id if @role_id.present? && !user.user_role_id.present?
    user.registration_type = :csv_upload
    user_scheme = Csv::UserSchemeBuilder.new(@scheme, user, @add_points, attr_hash).build
    user_scheme = Csv::LevelClubBuilder.new(user_scheme, attr_hash).build
    if attr_hash['representative_id'].present?
      lsr = @client.representatives.select(:id).where(id: attr_hash['representative_id'])
      representative = Csv::RepresentativeBuilder.new(lsr.last, user).build if lsr.present?
    end
    targets = Csv::TargetBuilder.new(user_scheme, club_target_names, attr_hash).build
    user
  end

  def batch_from_hash(rows)
    participant_ids = rows.collect { |row| participant_id(row) }.compact
    users = @client.users.where("lower(participant_id) IN (?) ", participant_ids)
    existing_users = Hash[*users.map { |u| [u.participant_id.downcase, u] }.flatten]
    rows.collect { |row| from_hash(row, existing_users) }
  end

  def unique_attribute
    "participant_id"
  end

  def template
    headers.join(",")
  end

  private
  def participant_id(attr_hash)
    attr_hash["participant_id"].try(:downcase)
  end

  def club_target_names
    @scheme.clubs.collect { |club| "#{club.name}_start_target" }.uniq
  end

end
