class UpdateDuplicateLinkCode < ActiveRecord::Migration
  def up
    sql = "SELECT DISTINCT(dup.unique_item_code_id), unique_item_codes.code FROM product_code_links INNER JOIN (SELECT unique_item_code_id FROM product_code_links GROUP BY unique_item_code_id HAVING count(id) > 1) dup ON product_code_links.unique_item_code_id = dup.unique_item_code_id inner join unique_item_codes ON unique_item_codes.id = dup.unique_item_code_id;"
    duplcate_records = execute(sql) if ActiveRecord::Base.connection.adapter_name == "Mysql2"
    duplcate_records.each do |record|
      DuplicateCodeLink.create(:unique_item_code_id => record[0], :code => record[1])
    end
  end

  def down
    DuplicateCodeLink.connection.execute('DELETE FROM duplicate_code_links');
  end
end
