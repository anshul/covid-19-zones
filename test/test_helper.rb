# frozen_string_literal: true

ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"
ENV["PROJECT_ENV"] = "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
require "minitest/focus"

require_relative "./test_helpers/assert_subset"
require_relative "./test_helpers/hash_diff_helper"
require_relative "./test_helpers/vcr_setup"

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new(color: true),
  ENV,
  Minitest.backtrace_filter
)

module ActiveSupport
  class TestCase
    # parallelize(workers: 2)

    fixtures :all

    Minitest::Test.make_my_diffs_pretty!

    def self.focus
      return puts("   ****** Ignoring focus ****** ") if ENV["NOFOCUS"] || ENV["CI"]

      super
    end
  end
end
