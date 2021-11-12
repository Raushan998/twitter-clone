class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.string :title
      t.integer :tweet_id
      t.integer :user_id
      t.boolean :is_active
      t.timestamps
    end
  end
end
