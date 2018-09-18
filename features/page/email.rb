module Page
  module Email

    def verify_link_in_order_confirmation_mail?
      #step %{""}
    end

    def verify_subject_in_order_confirmation_mail(subject)
      # code here
    end


    def verify_order_confirmation_email_is_received?(username,subject)
      user_email=username + "@mailinator.com"
      step %{"#{user_email}" should receive an email with subject "#{subject}"}
    end

  end
end

World(Page::Email)