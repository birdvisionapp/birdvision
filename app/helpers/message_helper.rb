module MessageHelper
  def alert_if(condition, message, options = {})
    if condition && message.present?
      alert_message = message_structure(message)
      content_tag(:div, alert_message, options)
    end
  end

  private

  def message_structure(message)
    if message.is_a? Array
      return content_tag(:ul) do
        message.collect { |msg| content_tag(:li, msg) }.join.html_safe
      end
    end
    message
  end
end
