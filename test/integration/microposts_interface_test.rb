require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:david)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface

  test "should show errors but not create micropost on invalid submission" do
    assert_no_difference 'Post.count' do
      post posts_path, params: { post: { content: "" } }
    end
    assert_select 'div#error_explanation'
  end

  test "should create a micropost on valid submission" do
    content = "This micropost really ties the room together"
    assert_difference 'Post.count', 1 do
      post posts_path, params: { post: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "should have micropost delete links on own profile page" do
    get user_path(@user)
    assert_select 'a', text: 'delete'
  end

  test "should be able to delete own micropost" do
    first_post = @user.posts.paginate(page: 1).first
    assert_difference 'Post.count', -1 do
      delete post_path(first_post)
    end
  end

  test "should not have delete links on other user's profile page" do
    get user_path(users(:Kohh))
    assert_select 'a', { text: 'delete', count: 0 }
  end

end
