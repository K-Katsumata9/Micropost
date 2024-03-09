class PostsController < ApplicationController
    before_action :logged_in_user?, only: [:create, :destroy]
    before_action :correct_user, only: [:destroy]

    def create
        @post = current_user.posts.build(post_params)
        @post.image.attach(params[:post][:image])
        if @post.save
            flash[:success] = "Post created!"
            redirect_to root_path
        else
            @feed_items = current_user.feed.paginate(page: params[:page],per_page: 10)
            render 'static_pages/home', status: :unprocessable_entity
        end
    end

    def destroy
        @post.destroy
        flash[:success] = "Micropost deleted"
        if request.referrer.nil?
            redirect_to root_url, status: :see_other
        else
            redirect_to request.referrer, status: :see_other
        end
    end

    private
        
        def post_params
            params.require(:post).permit(:content,:image)
        end

        def correct_user
            @post = current_user.posts.find_by(id: params[:id])
            redirect_to root_path, status: :see_other if @post.nil?
        end
end
