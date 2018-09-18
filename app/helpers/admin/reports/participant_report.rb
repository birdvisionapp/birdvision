module Admin::Reports::ParticipantReport
  include ViewsHelper
  include Admin::UsersHelper

  def to_csv options = {}
    CSV.generate do |csv|
      csv << csv_header(options)
      find_each(:batch_size => 6000) do |user|
        csv << csv_row(user, options)
      end
    end
  end

  def csv_header(options)
    header = ["Participant Id", "Username", "Full Name", "Email", "Mobile Number", "Activation Status", "Status", "Schemes(Points)", "Created On", "Uploaded Points", "Redeemed Points", "Balance Points",
              "Category", "Region", "Telecom Circle", "Address", "Pincode", "Landline No", "Notes"]
    if options[:role] == 'super_admin'
      header.unshift("Client")
      header.unshift("MSP") if options[:is_super_admin]
    end
    header
  end

  def csv_row(user, options)
    row = [user.participant_id,
           user.username,
           user.full_name,
           user.email,
           user.mobile_number,
           user.activation_status,
           user.status.titleize,
           points_per_scheme_csv(user),
           user.created_at.strftime("%d-%b-%Y"),
           user.total_points_for_past_and_active_schemes,
           user.total_redeemed_points,
           user.total_redeemable_points,
           user.role_display,
           user.region,
           user.circle_name,
           user.address,
           user.pincode,
           user.landline_number,
           user.notes]
    if options[:role] == 'super_admin'
      row.unshift(user.client_name)
      row.unshift(user.client.msp_name) if options[:is_super_admin]
    end
    row
  end

end

