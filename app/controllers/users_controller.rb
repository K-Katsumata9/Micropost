class UsersController < ApplicationController
  
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

  private
    # 許可するパラメータをprivateメソッドでカプセル化するのは
    # 非常によい手法であり、createとupdateの両方で同じ許可を与えられる
    # このメソッドを特殊化してユーザーごとに許可属性をチェックすることも可能
    def user_params
      params.require(:user).permit(:name, :email, 
                  :password, :password_confirmation)
    end

end
