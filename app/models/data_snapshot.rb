# frozen_string_literal: true

class DataSnapshot < ApplicationRecord
  validates :source, :api_code, :signature, :job_code, :raw_data, presence: true
end
