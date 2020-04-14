# frozen_string_literal: true

require "test_helper"

class FetchCovid19indiaTest < ::ActiveSupport::TestCase
  def record?
    return false if ENV["NOFOCUS"] || ENV["CI"]

    false
  end

  test "download from the covid19india api" do
    record_options = { record: record? ? :all : :none, match_requests_on: %i[uri] }
    ::ImportWiki.perform_task
    VCR.use_cassette("covid19india", record_options) do
      assert_difference "::Job.count" => 1, "::Patient.count" => 10_983 do
        cmd = ::FetchCovid19india.new
        assert cmd.call, "Command Failed: #{cmd.error_message}"
      end
    end
  end
end
