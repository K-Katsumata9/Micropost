require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                            email:           "user@invalid",
                            password:                 "foo",
                            password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template "users/new"
    assert_select "div#error_explanation"
    assert_select 'div[class="col-md-6 col-md-offset-3"]'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count' do
    post users_path, params: { user: { name:  "Koki Katsumata",
                           email:           "user@example.com",
                           password:                  "foobar",
                           password_confirmation:  "foobar" } }
    end
    assert_response :redirect
    follow_redirect!
    assert_template "users/show"
    assert_equal "Welcome to the Sample App!", flash[:success]
    assert_select "div.row"
  end
end
