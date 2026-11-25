require "test_helper"

class ResultsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "creates a result for the chat and redirects to its show page" do
    user = User.create!(email: "traveler@example.com", password: "password")
    chat = user.chats.create!
    sign_in user

    post chat_results_path(chat), params: {
      result: { destination: "Lisbon", price: "350", time: "5", content: "A five-day trip" }
    }

    result = Result.order(:created_at).last
    assert_redirected_to result_path(result)
    assert_equal result, chat.reload.result
  end

  test "shows a result belonging to the signed-in user" do
    user = User.create!(email: "traveler@example.com", password: "password")
    result = Result.create!(destination: "Paris", price: 250, time: 4)
    chat = user.chats.create!(result: result)
    sign_in user

    get result_path(result)

    assert_response :success
    assert_select "h1", "Paris"
    assert_select "dd", text: "250"
    assert_select "dd", text: "4 days"
    assert_select "a[href='#{chat_path(chat)}']", "Open conversation"
  end

  test "does not show another user's result" do
    user = User.create!(email: "traveler@example.com", password: "password")
    other_user = User.create!(email: "other@example.com", password: "password")
    result = Result.create!(destination: "Rome")
    other_user.chats.create!(result: result)
    sign_in user

    get result_path(result)

    assert_response :not_found
  end
end
