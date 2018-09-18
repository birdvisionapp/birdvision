class CreateDownloadReports < ActiveRecord::Migration
  def change
    create_table :download_reports do |t|
      t.string :filename
      t.text :url
      t.text :report_errors
      t.string :status

      t.timestamps
    end
  end
end
