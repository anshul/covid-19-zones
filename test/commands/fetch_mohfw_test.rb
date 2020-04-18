# frozen_string_literal: true

require "test_helper"

class FetchMohfwTest < ::ActiveSupport::TestCase
  test "download from the mohfw api" do
    record_options = { record: :none, match_requests_on: %i[uri] }
    VCR.use_cassette("mohfw", record_options) do
      assert_difference "::Job.count" => 1, "::DataSnapshot.count" => 1 do
        cmd = ::FetchMohfw.new
        assert cmd.call, "Command Failed: #{cmd.error_message}"
      end
    end
  end
end
