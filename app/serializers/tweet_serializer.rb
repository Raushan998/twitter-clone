class TweetSerializer < ActiveModel::Serializer
  attributes :id, :title, :retweets, :likes_count, :comments

  belongs_to :user, serializer: UserSerializer
  
  def retweets
    records = object.retweets
    unless records.blank?
      RetweetSerializer.new(records, {root: false})
    else
      nil
    end
  end

  def comments
    record = object.comments.where(is_active: true)
    unless record.blank?
      CommentSerializer.new(record, {root: false})
    else
      []
    end
  end

  def likes_count
    object.likes.length
  end
end
