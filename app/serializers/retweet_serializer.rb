class RetweetSerializer < ActiveModel::Serializer
  attributes :id, :title

  belongs_to :user, serializer: UserSerializer
end
