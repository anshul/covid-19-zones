require 'test_helper'

class UserTest < ActiveSupport::TestCase
  %i[admin].each do |user|
    test "users(:#{user}) is valid" do
      model = users(user)
      assert model.valid?, "Expected users(:#{user}) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
    end
  end
end

