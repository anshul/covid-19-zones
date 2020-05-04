# frozen_string_literal: true

require "test_helper"

module V2
  class UploadUnitOverridesTest < ::ActiveSupport::TestCase
    def valid_params
      {
        override_code: "in",
        csv:           "unit_code,category,date,value
in,invalid-category,12-04-2020,20
in/mh,infections,12-04-2020,20"
      }
    end

    test "upload succeeds" do
      cmd = ::V2::UploadUnitOverrides.new(**valid_params)
      assert_not cmd.call, "Command suceeded, expected failure"
      assert_equal "Row #1: Invalid category: invalid-category", cmd.error_message
    end
  end
end
