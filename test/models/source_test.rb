# frozen_string_literal: true

require "test_helper"

class SourceTest < ActiveSupport::TestCase
  test "(covid19india) fixture is valid" do
    model = sources(:covid19india)
    assert model.valid?, "Expected (covid19india) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end
end
