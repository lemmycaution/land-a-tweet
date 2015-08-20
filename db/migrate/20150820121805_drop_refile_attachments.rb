class DropRefileAttachments < ActiveRecord::Migration
  def up
    remove_index :refile_attachments, :namespace
    drop_table :refile_attachments
  end

  def down
    create_table :refile_attachments do |t|
      t.string :namespace, null: false
    end
    add_index :refile_attachments, :namespace
  end
end
