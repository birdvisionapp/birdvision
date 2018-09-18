class ClientTypeConstraint
  def initialize(allow_single_redemption)
    @allow_single_redemption = allow_single_redemption
  end

  def matches?(request)
    return true if request.env["warden"].nil?
    user = request.env["warden"].user
    user.nil? || UserScheme.for_user(user, request.path_parameters[:scheme_slug]).first.single_redemption? == @allow_single_redemption
  end
end