# frozen_string_literal: true

require "test_helper"

class JobTest < ActiveSupport::TestCase
  %i[sample].each do |job|
    test "jobs(:#{job}) is valid" do
      model = jobs(job)
      assert model.valid?, "Expected jobs(:#{job}) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
    end
  end
end
