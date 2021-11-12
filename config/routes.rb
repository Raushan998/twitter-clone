Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
    end
  end
  namespace :api do
    namespace :v1 do
      resources :tweets, only: [:index, :create, :update, :show] do
        get 'show_all_tweets', on: :collection
        post 'retweet', on: :member
        put 'like_tweet_status', on: :member
        post 'add_comment', on: :member
        put 'update_comment', on: :member
        get 'show_comment', on: :member
        get 'show_all_comments', on: :member
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
