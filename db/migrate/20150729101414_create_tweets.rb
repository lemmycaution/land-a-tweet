class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.text :text
      t.string :action

      t.timestamps null: false
    end
  end
end
