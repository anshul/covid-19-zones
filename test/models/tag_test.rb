# frozen_string_literal: true

require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "(mum_tag) fixture is valid" do
    model = tags(:mum_tag)
    assert model.valid?, "Expected (mum_tag) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end
end
