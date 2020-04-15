# frozen_string_literal: true

require "test_helper"

class TimeSeriesPointTest < ActiveSupport::TestCase
  %i[sample].each do |time_series_point|
    test "time_series_points(:#{time_series_point}) is valid" do
      model = time_series_points(time_series_point)
      assert model.valid?, "Expected time_series_points(:#{time_series_point}) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
    end
  end
end
