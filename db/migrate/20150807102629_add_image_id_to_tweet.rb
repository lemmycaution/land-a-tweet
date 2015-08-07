class AddImageIdToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :image_id, :string
  end
end
