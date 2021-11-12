class Api::V1::TweetsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show, :show_comment]
    before_action :set_tweet, only: [:update, :retweet, :like_tweet_status, :add_comment, :update_comment, :show, :show_all_comments]
    before_action :set_comment, only: [:update_comment, :show_comment]

    def index
        @tweets = Tweet.where(is_active: true).where(retweet_id: nil)
        render json: @tweets, each_serializer: TweetSerializer, adapter: :json, status: :ok
    end

    def create
        @tweet = Tweet.new(tweet_params)
        @tweet.assign_attributes({user: current_user})
        unless @tweet.save
            render json: @tweet.errors, adapter: :json, status: :unprocessable_entity
        else
            render json: @tweet, serializer: TweetSerializer, adapter: :json, status: :created
        end
    end
    
    def show
        render json: @tweet, serializer: TweetSerializer, adapter: :json, status: :ok
    end
    
    def show_all_tweets
        @tweets = current_user.tweets
        render json: @tweets, each_serializer: TweetSerializer, adapter: :json, status: :ok
    end

    def update 
        unless @tweet.update(tweet_update_params)
            render json: @tweet.errors, adapter: :json, status: :unprocessable_entity
        else
            render json: @tweet, serializer: TweetSerializer, adapter: :json, status: :ok
        end
    end
    
    def retweet
        if @tweet.user == current_user
            render json: {"error": "You cannot retweet on your own tweet"}, status: :unprocessable_entity
        else
            @children_tweet = @tweet.retweets.new(tweet_params)
            @children_tweet.assign_attributes({user: current_user})
            unless @children_tweet.save
                render json: @children_tweet.errors, adapter: :json, status: :unprocessable_entity
            else
                render json: @children_tweet, serializer: RetweetSerializer, adapter: :json, status: :created
            end
        end
    end
    
    def like_tweet_status
        if params[:status] == "like"

            unless @tweet.user == current_user
                if @tweet.likes.include? current_user.id
                    render json: {"error": "You have already liked the tweet"}, status: :unprocessable_entity
                else
                    @tweet.likes.push(current_user.id)
                    @tweet.save!
                    render json: @tweet, serializer: TweetSerializer, adapter: :json, status: :ok
                end
            else
                render json: {"error": "You cannot like your own tweet"}, status: :unprocessable_entity
            end
        elsif params[:status] == "unlike"
            if @tweet.likes.include? current_user.id
                @tweet.likes.delete(current_user.id)
                @tweet.save!
                render json: @tweet, serializer: TweetSerializer, adapter: :json, status: :ok
            else
                render json: {"error": "You cannot unlike the tweet"}, status: :unprocessable_entity
            end
        else
            render json: {"error": "Invalid status"}, status: :unprocessable_entity
        end
    end

    def add_comment
        @comment = @tweet.comments.new(comment_params)
        @comment.assign_attributes({user: current_user})
        unless @comment.save
            render json: {"error": "comments cannot be saved!!!"}, status: :unprocessable_entity
        else
            render json: @comment, serializer: CommentSerializer, adapter: :json, status: :created
        end
    end

    def update_comment
        unless @comment.update(comment_update_params)
            render json: {"error": "Comment can't be updated!!!"}, status: :unprocessable_entity
        else
            render json: @comment, serializer: CommentSerializer, adapter: :json, status: :ok
        end
    end
    
    def show_comment
        render json: @comment, serializer: CommentSerializer, adapter: :json, status: :ok
    end
    
    def show_all_comments
        @comments = @tweet.comments.where(user_id: current_user.id)
        render json: @comments, each_serializer: CommentSerializer, adapter: :json, status: :ok
    end

    private

    def tweet_params
        params.require(:tweet).permit(:title, :is_active)
    end
    
    def tweet_update_params
        params.require(:tweet).permit(:id, :title, :is_active)
    end

    def comment_params
        params.require(:comment).permit(:title, :is_active)
    end

    def comment_update_params
        params.require(:comment).permit(:id, :title, :is_active)
    end

    def set_tweet
        @tweet = Tweet.find(params[:id])
    end

    def set_comment
        @comment = Comment.find(params[:comment][:id])
    end
end
