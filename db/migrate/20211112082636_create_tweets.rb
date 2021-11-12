class CreateTweets < ActiveRecord::Migration[6.1]
  def change
    create_table :tweets do |t|
      t.integer :user_id
      t.integer :retweet_id
      t.string :title
      t.boolean :is_active
      t.timestamps
    end
  end
end
