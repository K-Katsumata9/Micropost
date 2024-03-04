require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:david)
    @user2 = users(:steve)
  end

  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_equal "Please Login!", flash[:danger]
    assert_redirected_to login_path
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user:{ name: @user.name, email: @user.email } }
    assert_equal "Please Login!", flash[:danger]
    assert_redirected_to login_path
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@user2)
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_equal "対象ユーザーでログインしてください", flash[:danger]
    assert_redirected_to root_path
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@user2)
    patch user_path(@user), params: { user:{ name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_equal "対象ユーザーでログインしてください", flash[:danger]
    assert_redirected_to root_path
  end
  
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@user2)
    assert_not @user2.admin?
    patch user_path(@user2), params: {
                                    user: { name:                 @user2.name,
                                            email:               @user2.email,
                                            password:                "foobar",
                                            password_confirmation:   "foobar",
                                            admin: 1 } }
    assert_not @user2.admin?
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@user2)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
