# frozen_string_literal: true

class Patient < ApplicationRecord
  validates :code, :external_code, :source, :zone_code, :district_code, :city_code, :state_code, :country_code, presence: true

  STATUSES = %w[confirmed recovered deceased].freeze

  validates :status, inclusion: { in: STATUSES, message: "'%{value}' is not one of valid status: #{STATUSES.to_sentence}" }, presence: true

  has_many :taggings, as: :taggable, dependent: :destroy
end
