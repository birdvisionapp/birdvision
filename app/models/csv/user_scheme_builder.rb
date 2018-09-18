module Csv
  class UserSchemeBuilder
    def initialize(scheme, user, add_points, attrs)
      @scheme = scheme
      @user = user
      @add_points = add_points
      @attrs = attrs
    end

    def build
      attrs = {:current_achievements => @attrs.delete('current_achievements'), :region => @attrs.delete('region'), :notify_points_update => true }
      user_scheme = @user.user_schemes.find { |us| us.scheme_id == @scheme.id }
      points = @attrs.delete("points")
      if points.to_i < 0 && @scheme.client.allow_total_points_deduction? && (@user.id.present? && @user.total_redeemable_points >= points.to_i.abs)
        ex_redeemed_points = user_scheme.present? ? user_scheme.redeemed_points : 0
        attrs.merge!(:redeemed_points => (ex_redeemed_points + points.to_i.abs) )
      else
        if user_scheme.present? && @add_points
          attrs.merge!(:total_points => user_scheme.total_points + (points || 0).to_i)
        else
          attrs.merge!(:total_points => points)
        end
      end

      attrs = attrs.delete_if { |k, v| v.blank? }

      if user_scheme.nil?
        user_scheme = @user.user_schemes.build({:scheme_id => @scheme.id}.merge(attrs))
        return user_scheme
      end
      user_scheme.assign_attributes(attrs)
      user_scheme
    end
  end
end
