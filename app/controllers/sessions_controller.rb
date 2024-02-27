class SessionsController < ApplicationController
  
  def new

  end

  def create
    @user = User.find_by(email: params[:session][:email]) 
    if @user && @user.authenticate(params[:session][:password])
      reset_session      # ログインの直前に必ずこれを書くこと
      log_in(@user)
      flash[:success] = "Welcome to the Sample App!"
      redirect_to user_url(@user)
    else 
      flash.now[:danger] = 'Invalid email/password combination' # 本当は正しくない
      render 'sessions/new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path, status: :see_other
  end

end
