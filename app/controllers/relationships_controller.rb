class RelationshipsController < ApplicationController
    before_action :logged_in_user?, only: [:create, :destroy]

    def create
        @user = User.find(params[:followed_id])
        current_user.follow(@user)
        redirect_to user_path(@user)
    end
  
    def destroy
        @user = Relationship.find(params[:id]).followed
        current_user.unfollow(@user)
        redirect_to user_path(@user), status: :see_other
      end

end
