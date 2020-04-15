# frozen_string_literal: true

require "test_helper"

class ZoneTest < ActiveSupport::TestCase
  test "countries(:india) is valid" do
    model = countries(:india)
    assert model.valid?, "Expected countries(:india) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end

  test "states(:maharashtra) is valid" do
    model = states(:maharashtra)
    assert model.valid?, "Expected states(:maharashtra) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end

  test "districts(:mumbai_district) is valid" do
    model = districts(:mumbai_district)
    assert model.valid?, "Expected districts(:mumbai_district) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end

  test "cities(:mumbai_city) is valid" do
    model = cities(:mumbai_city)
    assert model.valid?, "Expected (mumbai_city) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end

  test "localities(:dadar) is valid" do
    model = localities(:dadar)
    assert model.valid?, "Expected localities(:dadar) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end
end
