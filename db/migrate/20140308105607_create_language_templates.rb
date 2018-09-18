class CreateLanguageTemplates < ActiveRecord::Migration
  def change
    table_name = 'language_templates'
    template_field = 'template'
    create_table table_name.to_sym do |t|
      t.string :name, :null => false
      t.text template_field.to_sym
      t.string :status, :default => 'active'
      t.timestamps
    end
    execute("ALTER TABLE #{table_name} MODIFY `#{template_field}` text CHARACTER SET utf8 COLLATE utf8_unicode_ci;") if ActiveRecord::Base.connection.adapter_name == "Mysql2"
  end
end
