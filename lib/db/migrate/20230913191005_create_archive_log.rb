class CreateArchiveLog < ActiveRecord::Migration[7.0]
  def change
    create_table :archive_logs do |t|
      t.string :class_type
      t.integer :class_id
      t.string :class_identifier
      t.text :payload
      t.string :action
      t.boolean :is_exported

      t.timestamps
    end
  end
end
