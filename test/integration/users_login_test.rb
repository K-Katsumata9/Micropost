require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:david)
  end

  #テストユーザーとしてログインする
  def log_in_as(user,remember_me)
    post login_path,  params: { 
      session: { email: user.email, password: "foobar", remember_me: remember_me } }
  end

  test "login with valid email/invalid password" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: { session: {email: @user.email,
                               password: "invalid"} }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_equal 'Invalid email/password combination', flash.now[:danger]
    assert_template 'sessions/new'
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: { session: {email: @user.email,
                               password: "foobar"} }
    assert is_logged_in?  
    assert_response :redirect
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_template "users/show"
    assert_equal "Success Login!", flash[:success]
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    delete logout_path
    assert_response :see_other
    assert_not is_logged_in?    
    assert_redirected_to root_path
    delete logout_path
    follow_redirect! 
    assert_template "static_pages/home"
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", user_path(@user), count: 0
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
  end

  test "login with remembering" do
    log_in_as(@user,1)
    assert_not cookies[:remember_token].blank?
  end

  test "login without remembering" do
    log_in_as(@user,0)
    assert cookies[:remember_token].blank?
  end

end
