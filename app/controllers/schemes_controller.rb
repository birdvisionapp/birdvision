class SchemesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @hide_search = true
    @show_dashboard = current_user.user_schemes.browsable.any?(&:current_achievements)
    @schemes = {
        :ready_for_redemption => current_user.user_schemes.includes(:level).joins(:scheme).merge(Scheme.redeemable).map { |user_scheme|
          OpenStruct.new(:scheme => user_scheme.scheme, :user_scheme => user_scheme, :can_proceed => true, :button_text => "Redeem Rewards",
                         :message => "You can redeem these rewards until #{as_date(user_scheme.scheme.redemption_end_date)}",
                         :points_text => user_points(user_scheme),
                         :date_range => "#{as_date(user_scheme.scheme.redemption_start_date)} to #{as_date(user_scheme.scheme.redemption_end_date)}")
        },
        :upcoming => current_user.user_schemes.includes(:level).joins(:scheme).merge(Scheme.pre_redemption).map { |user_scheme|
          OpenStruct.new(:scheme => user_scheme.scheme, :user_scheme => user_scheme, :can_proceed => true, :button_text => "View Rewards",
                         :message => "You can redeem these rewards from #{as_date(user_scheme.scheme.redemption_start_date)}",
                         :points_text => user_points(user_scheme),
                         :date_range => "#{as_date(user_scheme.scheme.start_date)} to #{as_date(user_scheme.scheme.redemption_end_date)}")
        },
        :past => current_user.user_schemes.includes(:level).joins(:scheme).merge(Scheme.expired).map { |user_scheme|
          OpenStruct.new(:scheme => user_scheme.scheme, :user_scheme => user_scheme, :can_proceed => false, :button_text => "",
                         :points_text => user_points(user_scheme),
                         :message => "The Redemption period for this scheme is over",
                         :date_range => "")
        }
    }
  end

  def participant_speedometer
    render :json => ParticipantDashboard.new(current_user).speedometer_data
  end

  def participant_leaderboard
    render :json => ParticipantDashboard.new(current_user).leaderboard_data
  end
  
  def approve_al_user_details
 
  end
  
  def send_al_user_details
    UserMailer.al_user_change_request(current_user, params[:user]).deliver
    redirect_to schemes_path
  end
  
  def al_point_report
    @dms = AlTransaction.where(:user_id => current_user.id).page(params[:page])
  end

  private

  def user_points(user_scheme)
    return nil unless user_scheme.show_points?
    "#{view_context.bvc_currency(user_scheme.total_points)} points earned"
  end

  def as_date(date)
    date.to_date.to_formatted_s(:long_ordinal)
  end

end

