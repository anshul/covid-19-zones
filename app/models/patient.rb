# frozen_string_literal: true

class Patient < ApplicationRecord
  has_many :tags, dependent: :destroy
end
