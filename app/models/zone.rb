# frozen_string_literal: true

class Zone < ApplicationRecord
  has_many :tags, dependent: :destroy
end
