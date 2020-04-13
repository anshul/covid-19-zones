# frozen_string_literal: true

class Zone < ApplicationRecord
  validates :slug, :code, :type, presence: true

  has_many :taggings, as: :taggable, dependent: :destroy
end
