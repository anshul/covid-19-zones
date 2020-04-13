# frozen_string_literal: true

require "test_helper"

class SinglePageAppControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get single_page_app_index_url
    assert_response :success
  end
end
