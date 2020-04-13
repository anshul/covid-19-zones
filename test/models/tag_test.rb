# frozen_string_literal: true

require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "(wi_tag) fixture is valid" do
    model = tags(:wi_tag)
    assert model.valid?, "Expected (wi_tag) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end
end
