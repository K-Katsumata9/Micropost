class UsersController < ApplicationController
  before_action :logged_in_user?, only: [:edit, :update, :index, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  def new
    @user = User.new
  end
  
  def show
    @user = User.find_by(id: params[:id])
  end 

  def create
    @user = User.new(user_params)
    if @user.save
      reset_session      # ログインの直前に必ずこれを書くこと
      log_in(@user)
      flash[:success] = "Welcome to the Sample App!"
      redirect_to user_url(@user)
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

  private

    def logged_in_user?
      if current_user.nil?
        flash[:danger] = 'Please Login!'
        store_location
        redirect_to login_path, status: :see_other
      end
    end

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
