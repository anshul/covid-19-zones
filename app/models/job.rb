# frozen_string_literal: true

class Job < ApplicationRecord
  validates :code, :slug, presence: true
end
