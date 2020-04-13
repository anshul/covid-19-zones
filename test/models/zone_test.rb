# frozen_string_literal: true

require "test_helper"

class ZoneTest < ActiveSupport::TestCase
  test "zone(country) (india) fixture is valid" do
    model = countries(:india)
    assert model.valid?, "Expected (india) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end

  test "zone(state) (maharashtra) fixture is valid" do
    model = states(:maharashtra)
    assert model.valid?, "Expected (maharashtra) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end

  test "zone(city) (mumbai_city) fixture is valid" do
    model = cities(:mumbai_city)
    assert model.valid?, "Expected (mumbai_city) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end

  test "zone(district) (mumbai_district) fixture is valid" do
    model = districts(:mumbai_district)
    assert model.valid?, "Expected (mumbai_district) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end
end
