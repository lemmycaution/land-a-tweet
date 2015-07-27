class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities, id: :uuid, default: "uuid_generate_v4()"  do |t|
      t.json :payload

      t.timestamps null: false
    end
  end
end
