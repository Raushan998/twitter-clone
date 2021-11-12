require 'rails_helper'

RSpec.describe "Api::V1::Tweets", type: :request do
  let!(:user) {create(:user)}
  let!(:tweets) {create_list(:tweet, 10)}
  before(:each) do 
    @sign_in_url = '/api/v1/auth/sign_in'
    @login_params = {
        email: user.email,
        password: user.password
    }
end
  describe "GET /index" do
    context "(success)" do
      before {get "/api/v1/tweets"}
      it "returns list of tweets" do
        expect(json).not_to be_empty
        expect(json["tweets"].count).to eql(10)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "POST /create" do
    context "(success)" do
      before do
        #login @user created in the beore block in outer describe block
            post @sign_in_url, params: @login_params, as: :json
            @headers = {
                'uid' => response.headers['uid'],
                'client' => response.headers['client'],
                'access-token' => response.headers['access-token']
            }
      end
      let!(:valid_attributes){
        {
           "tweet":{
             "title": "How the people are over here?",
             "is_active": true
           }
        }
      }
      before {post "/api/v1/tweets", params: valid_attributes, headers: @headers}
      it "create a new tweet for particular user" do
        expect(response).to have_http_status(201)
        expect(json["tweet"]["title"]).to eql("How the people are over here?")
        expect(json["tweet"]["user"]["username"]).to eql(user.username)
      end
    end

    context "(failure)" do
      let!(:valid_attributes){
        {
           "tweet":{
             "title": "How the people are over here?",
             "is_active": true
           }
        }
      }
      before {post "/api/v1/tweets", params: valid_attributes}
      it "returns invalid request for login user" do
        expect(response).to have_http_status(401)
        expect(json["errors"]).to eql(["You need to sign in or sign up before continuing."])
      end
    end
  end

  describe "PUT /Update" do
    context "(success)" do
      let!(:tweet) {create(:tweet)}
      before do
        #login @user created in the beore block in outer describe block
            post @sign_in_url, params: @login_params, as: :json
            @headers = {
                'uid' => response.headers['uid'],
                'client' => response.headers['client'],
                'access-token' => response.headers['access-token']
            }
      end
      let!(:valid_attributes){
        {
          "tweet":{
            "id": tweet.id,
            "title": "It is raining too much today....",
            "is_active": true
          }
        }
      }
      before {put "/api/v1/tweets/#{tweet.id}", params: valid_attributes, headers: @headers}
      it "returns the updated tweet" do
        expect(response).to have_http_status(200)
        expect(json["tweet"]["title"]).to eql("It is raining too much today....")
      end
    end
  end
   
  describe "GET /Show Tweet" do
    let!(:tweet) {create(:tweet)}
    context "(success)" do
      before {get "/api/v1/tweets/#{tweet.id}"}

      it "returns the tweet reference to particular id" do
        expect(response).to have_http_status(200)
        expect(json["tweet"]["title"]).to eql(tweet.title)
      end
    end
  end
  
  describe "GET /Show All Tweets" do
    let!(:user2) {create(:user)}
    let!(:tweets1) {create_list(:tweet, 10, is_active: true, user: user2)}
    let!(:tweets2) {create_list(:tweet, 10, is_active: false, user: user2)}
    let!(:login_params){
      {
        email: user2.email,
        password: user2.password
      }
    }
    before do
      #login @user created in the beore block in outer describe block
          post @sign_in_url, params: login_params, as: :json
          @headers = {
              'uid' => response.headers['uid'],
              'client' => response.headers['client'],
              'access-token' => response.headers['access-token']
          }
    end
    context "(success)" do
      before {get "/api/v1/tweets/show_all_tweets", headers: @headers}

      it "returns the tweet reference to particular id" do
        expect(response).to have_http_status(200)
        expect(json["tweets"].count).to eql(20)
      end
    end
  end

  describe "POST /Retweet" do
    context "(success)" do
      let!(:tweet) {create(:tweet)}
      before do
        #login @user created in the beore block in outer describe block
            post @sign_in_url, params: @login_params, as: :json
            @headers = {
                'uid' => response.headers['uid'],
                'client' => response.headers['client'],
                'access-token' => response.headers['access-token']
            }
      end
      let!(:valid_attributes){
        {
          "tweet":{
            "title": "It is raining too much today....",
            "is_active": true
          }
        }
      }
      before {post "/api/v1/tweets/#{tweet.id}/retweet", params: valid_attributes, headers: @headers}
      it "returns the updated tweet" do
        expect(response).to have_http_status(201)
        expect(json["tweet"]["title"]).to eql("It is raining too much today....")
      end
    end

    context "(failure)" do
      let!(:tweet) {create(:tweet, user: user)}
      before do
        #login @user created in the beore block in outer describe block
            post @sign_in_url, params: @login_params, as: :json
            @headers = {
                'uid' => response.headers['uid'],
                'client' => response.headers['client'],
                'access-token' => response.headers['access-token']
            }
      end
      let!(:valid_attributes){
        {
          "tweet":{
            "title": "It is raining too much today....",
            "is_active": true
          }
        }
      }
      before {post "/api/v1/tweets/#{tweet.id}/retweet", params: valid_attributes, headers: @headers}
      it "returns the updated tweet" do
        expect(response).to have_http_status(422)
        expect(json["error"]).to eql("You cannot retweet on your own tweet")
      end
    end
  end

  describe "PUT /like_tweet_status" do
    context "(success)" do
      let!(:tweet) {create(:tweet)}
      let!(:valid_attributes){
        {
          "status": "like"
        }
      }
      before do
        #login @user created in the beore block in outer describe block
            post @sign_in_url, params: @login_params, as: :json
            @headers = {
                'uid' => response.headers['uid'],
                'client' => response.headers['client'],
                'access-token' => response.headers['access-token']
            }
      end
      before {put "/api/v1/tweets/#{tweet.id}/like_tweet_status", params: valid_attributes, headers: @headers}
      it "returns the tweet with update liked tweet count" do
        expect(response).to have_http_status(200)
        expect(json["tweet"]["likes_count"]).to eql(1)
      end
    end

    context "(success)" do
      let!(:tweet) {create(:tweet, likes: [user.id])}
      let!(:valid_attributes){
        {
          "status": "unlike"
        }
      }
      before do
        #login @user created in the beore block in outer describe block
            post @sign_in_url, params: @login_params, as: :json
            @headers = {
                'uid' => response.headers['uid'],
                'client' => response.headers['client'],
                'access-token' => response.headers['access-token']
            }
      end
      before {put "/api/v1/tweets/#{tweet.id}/like_tweet_status", params: valid_attributes, headers: @headers}
      it "returns the tweet with updated unliked tweet count" do
        expect(response).to have_http_status(200)
        expect(json["tweet"]["likes_count"]).to eql(0)
      end
    end

    context "(failure)" do
      let!(:tweet) {create(:tweet, user: user)}
      let!(:valid_attributes){
        {
           "status": "like"
        }
      }
      before do
        post @sign_in_url, params: @login_params, as: :json
        @headers = {
            'uid' => response.headers['uid'],
            'client' => response.headers['client'],
            'access-token' => response.headers['access-token']
        }
      end
      before {put "/api/v1/tweets/#{tweet.id}/like_tweet_status", params: valid_attributes, headers: @headers}
      it "returns the tweet with updated unliked tweet count" do
        expect(json["error"]).to eql("You cannot like your own tweet")
        expect(response).to have_http_status(422)
      end
    end

    context "(failure)" do
      let!(:tweet) {create(:tweet, likes: [user.id])}
      let!(:valid_attributes){
        {
           "status": "like"
        }
      }
      before do
        post @sign_in_url, params: @login_params, as: :json
        @headers = {
            'uid' => response.headers['uid'],
            'client' => response.headers['client'],
            'access-token' => response.headers['access-token']
        }
      end
      before {put "/api/v1/tweets/#{tweet.id}/like_tweet_status", params: valid_attributes, headers: @headers}
      it "returns the tweet with updated unliked tweet count" do
        expect(json["error"]).to eql("You have already liked the tweet")
        expect(response).to have_http_status(422)
      end
    end

    context "(failure)" do
      let!(:tweet) {create(:tweet)}
      let!(:valid_attributes){
        {
           "status": "unlike"
        }
      }
      before do
        post @sign_in_url, params: @login_params, as: :json
        @headers = {
            'uid' => response.headers['uid'],
            'client' => response.headers['client'],
            'access-token' => response.headers['access-token']
        }
      end
      before {put "/api/v1/tweets/#{tweet.id}/like_tweet_status", params: valid_attributes, headers: @headers}
      it "returns the tweet with updated unliked tweet count" do
        expect(json["error"]).to eql("You cannot unlike the tweet")
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Add Comment" do
    let!(:tweet) {create(:tweet)}
    before do
      post @sign_in_url, params: @login_params, as: :json
      @headers = {
          'uid' => response.headers['uid'],
          'client' => response.headers['client'],
          'access-token' => response.headers['access-token']
      }
    end
    context "(success)" do
      let!(:valid_attributes){
        {
          comment:{
            title: "I don't agree with you.....",
            is_active: true
          }
        }
      }
      before {post "/api/v1/tweets/#{tweet.id}/add_comment", params: valid_attributes, headers: @headers}
      it "returns the comment with that user" do
        expect(json["comment"]["title"]).to eql("I don't agree with you.....")
        expect(response).to have_http_status(201)
      end
    end
  end

  describe "Update Comment" do
    let!(:tweet) {create(:tweet)}
    let!(:comment) {create(:comment, tweet: tweet, is_active: false)}
    before do
      post @sign_in_url, params: @login_params, as: :json
      @headers = {
          'uid' => response.headers['uid'],
          'client' => response.headers['client'],
          'access-token' => response.headers['access-token']
      }
    end
    context "(success)" do
      let!(:valid_attributes){
        {
          comment:{
            id: comment.id,
            title: "I don't agree with you.....",
            is_active: true
          }
        }
      }
      before {put "/api/v1/tweets/#{tweet.id}/update_comment", params: valid_attributes, headers: @headers}
      it "returns the comment with that user" do
        expect(json["comment"]["title"]).to eql("I don't agree with you.....")
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "show comment" do
    let!(:tweet) {create(:tweet)}
    let!(:comment) {create(:comment, tweet: tweet, user: user, is_active: true)}
    let!(:valid_attributes){
      {
        comment:{
          id: comment.id
        }
      }
    }
    before {get "/api/v1/tweets/#{tweet.id}/show_comment", params: valid_attributes}
      it "returns the particular comment with that user" do
        expect(json["comment"]["title"]).to eql(comment.title)
        expect(response).to have_http_status(200)
      end
  end

  describe "show all comment" do
    let!(:user2) {create(:user)}
    let!(:tweet) {create(:tweet)}
    let!(:comments1) {create(:comment, tweet: tweet, user: user2, is_active: true)}
    let!(:comments2) {create(:comment, tweet: tweet, user: user2, is_active: false)}
    let!(:login_params){
      {
        email: user2.email,
        password: user2.password
      }
    }
    before do
      #login @user created in the beore block in outer describe block
          post @sign_in_url, params: login_params, as: :json
          @headers = {
              'uid' => response.headers['uid'],
              'client' => response.headers['client'],
              'access-token' => response.headers['access-token']
          }
    end
    before {get "/api/v1/tweets/#{tweet.id}/show_all_comments", headers: @headers}
      it "returns the particular comment with that user" do
        expect(json["comments"].count).to eql(2)
        expect(response).to have_http_status(200)
      end
  end

end