# frozen_string_literal: true

class Tag < ApplicationRecord
  validates :slug, :code, presence: true

  has_many :taggings, as: :taggable, dependent: :destroy
end
