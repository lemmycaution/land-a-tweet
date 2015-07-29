class AddStatusToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :status, :text
  end
end
