module Admin::ItemHelper

  def get_client_names_for item
    #done for displaying client names in new line in table
    client_names(item).join(", \n")
  end

  def get_client_names_csv_for item
    client_names(item).join(", ")
  end

  private
  def client_names(item)
    item.client_items.available.joins(:client).pluck(:client_name).uniq
  end
end

