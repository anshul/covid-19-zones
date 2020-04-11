# frozen_string_literal: true

require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "Project.env is test" do
    assert Project.env.test?, "Expected to be in test environment, got Project.env: #{Project.env}"
  end
end
