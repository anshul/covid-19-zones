# frozen_string_literal: true

require "test_helper"

class RecomputeTest < ::ActiveSupport::TestCase
  test "recompute should work" do
    cmd = ::Recompute.new
    assert_equal 1, ::Patient.count
    assert cmd.call, "Command Failed: #{cmd.error_message}"
    assert_equal 5, ::TimeSeriesPoint.count
  end
end
