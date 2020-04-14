# frozen_string_literal: true

require "test_helper"

class ZonesControllerTest < ActionDispatch::IntegrationTest
  test "should list countries" do
    get zones_list_url
  end

  test "should list states" do
    get zones_list_url, params: { code: "in" }
  end
end
