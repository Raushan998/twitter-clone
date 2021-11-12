class AddLikesArrayColumnToTweets < ActiveRecord::Migration[6.1]
  def change
    add_column :tweets, :likes, :integer, array: true, default: []
  end
end
