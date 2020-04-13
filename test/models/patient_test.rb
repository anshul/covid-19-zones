# frozen_string_literal: true

require "test_helper"

class PatientTest < ActiveSupport::TestCase
  test "(first_mumbai_patient) fixture is valid" do
    model = patients(:first_mumbai_patient)
    assert model.valid?, "Expected (first_mumbai_patient) to be valid, got errors: #{model.errors.full_messages.to_sentence}"
  end
end
