class CsvRewardProductPoint
  def initialize(client)
    @client = client
  end

  def headers
    common_headers = %w(al_part_no  points)
  end

  def from_hash(attr_hash, existing_reward_items)
    attr_hash.keep_if { |key, value| value.present? && headers.include?(key) }
    prod_point = Csv::ProdPtBuilder.new(existing_reward_items[al_part_no(attr_hash)], attr_hash).build
    if existing_reward_items[al_part_no(attr_hash)].nil?
      reward_item_point = Csv::RewardItemPointBuilder.new(prod_point, attr_hash).build
    end
    prod_point
  end

  def batch_from_hash(rows)
    al_part_nos = rows.collect { |row| al_part_no(row) }.compact
    reward_items = RewardItem.where("lower(al_part_no) IN (?) ", al_part_nos)
    existing_reward_items = Hash[*reward_items.map { |u| [u.al_part_no.downcase, u] }.flatten]
    rows.collect { |row| from_hash(row, existing_reward_items) }
  end

  def unique_attribute
    "al_part_no"
  end

  def template
    headers.join(",")
  end

  private
  def al_part_no(attr_hash)
    attr_hash["al_part_no"].try(:downcase)
  end

end