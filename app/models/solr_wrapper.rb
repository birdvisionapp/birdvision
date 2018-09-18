class SolrWrapper

  def self.search_catalog(search, user, user_scheme)
    response = query(search, user, user_scheme)
    stats = query(search.for_stats(:points), user, user_scheme)
    SearchResponse.new(response, stats)
  end

  class SearchResponse
    extend Forwardable
    def_delegators :@response, :results, :total

    def initialize(response, stats)
      @response = response
      @stats = stats
    end

    def stats_by field
      @stats.as_json['solr_result']['stats']['stats_fields'][Sunspot::Setup.for(ClientItem).field(field).indexed_name]
    end

    def facet_by(facet_key)
      @response.facet(facet_key).rows
    end
  end

  private
  def self.stats_field(stats)
    Sunspot::Setup.for(ClientItem).field(stats).indexed_name
  end

  def self.query(search, user, user_scheme)
    Sunspot.search(ClientItem) do
      data_accessor_for(ClientItem.active_items.active_item).include = [:item]
      fulltext search.keyword do
        boost_fields :title => 2.0
      end
      with(:deleted).equal_to(false)
      with(:client_id).equal_to(user.client.id)
      with(:scheme_ids, [user_scheme.scheme.id])
      with(:level_club_ids, user_scheme.applicable_level_clubs.collect(&:id))
      without(:points, nil)
      with(:points).between(search.point_range_value) if search.point_range_value.present?
      with(:category).equal_to(search.category) if search.category.present?
      with(:parent_category).equal_to(search.parent_category) if search.parent_category.present?
      paginate :page => search.page_value, :per_page => search.per_page_value
      facet :category
      facet :parent_category
      adjust_solr_params do |params|
        params[:stats] = true
        params['stats.field'] = stats_field(search.stats)
      end if search.stats.present?
      order_by(:score, :desc)
      order_by(:points, :asc)
    end
  end

end


