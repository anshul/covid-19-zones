# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :patients, dependent: :destroy
  has_many :zones, dependent: :destroy
end
