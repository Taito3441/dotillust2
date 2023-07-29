class UsersController < ApplicationController
    def show
        @user = User.find(params[:id]) 
        @total_likes = @user.illusts.sum(&:likes_count) 
        
    end

    def index
        @users = User.all.includes(:illusts, :likes)
        @most_liked_illusts = @users.map do |user|
            user.illusts.order('likes_count DESC').first
        end
        @most_recent_illusts = @users.map do |user|
            user.illusts.order('created_at DESC').first
        end
    end

    def following
        @user  = User.find(params[:id])
        @users = @user.followings.includes(:illusts, :likes)
        @most_liked_illusts = @users.map do |user|
            user.illusts.order('likes_count DESC').first
        end
        @most_recent_illusts = @users.map do |user|
            user.illusts.order('created_at DESC').first
        end
        render 'show_follow'
    end

    def followers
        @user  = User.find(params[:id])
        @users = @user.followers.includes(:illusts, :likes)
        @most_liked_illusts = @users.map do |user|
            user.illusts.order('likes_count DESC').first
        end
        @most_recent_illusts = @users.map do |user|
            user.illusts.order('created_at DESC').first
        end
        render 'show_follower'
    end

    def destroy
        @user = User.find(params[:id])
        if current_user == @user || current_user.admin?
            @user.destroy
            flash[:success] = 'User deleted'
            redirect_to users_url
        else
            flash[:alert] = 'You do not have permission to delete this user'
            redirect_to @user
        end
    end
    

end