class UsersController < ApplicationController
  before_action :logged_in_user?, only: [:edit, :update, :index, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @users = User.where(activated: 1 ).paginate(page: params[:page], per_page: 10)
  end

  def new
    @user = User.new
  end
  
  def show
    @user = User.find_by(id: params[:id])
    @posts = @user.posts.paginate(page: params[:page], per_page: 10)
    redirect_to root_url and return unless @user.activated?
  end 

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'users/new', status: :unprocessable_entity
    end
  end

  def edit
  end 

  def update
      if @user.update(user_params)
        flash[:success] = "Profile Completed!"
        redirect_to user_path(@user)
      else
        render "users/edit", status: :unprocessable_entity
      end
  end 
  
  def destroy
    if @user = User.find_by(id: params[:id])
      @user.destroy
      flash[:success] = "Delete Completed!"
      redirect_to users_url, status: :see_other      
    end
  end

  def activation_email
    if @user = User.find_by(confirmation_token: params[:token])
      unless @user.expired?
        @user.activate
      end
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      unless current_user?(@user)
        flash[:danger] = '対象ユーザーでログインしてください'
        redirect_to root_path
      end
    end

    def admin_user
      redirect_to root_path, status: :see_other unless current_user.admin?
    end

    # 許可するパラメータをprivateメソッドでカプセル化するのは
    # 非常によい手法であり、createとupdateの両方で同じ許可を与えられる
    # このメソッドを特殊化してユーザーごとに許可属性をチェックすることも可能
    def user_params
      params.require(:user).permit(:name, :email, 
                  :password, :password_confirmation)
    end

end
