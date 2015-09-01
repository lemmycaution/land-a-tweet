class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :slug
      t.text :body

      t.timestamps null: false
    end
    add_index :pages, :slug, unique: true
  end
end
