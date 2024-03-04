require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:david)
    @user2 = users(:steve)
  end

  test "index including pagination" do
    log_in_as(@user,remember_me: '0')
    get users_path
    assert_template "users/index"
    User.paginate(page: 1,per_page: 10).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1,per_page: 10)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @user
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@user2)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  test "index as non-admin" do
    log_in_as(@user2)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

end
