class Tweet < ApplicationRecord
    belongs_to :user
    has_many :retweets, class_name: "Tweet", foreign_key: "retweet_id"
    has_many :comments
end
