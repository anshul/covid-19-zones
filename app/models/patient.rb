# frozen_string_literal: true

class Patient < ApplicationRecord
  validates :code, :external_code, :source, :zone_code, presence: true

  STATUSES = %w[unknown confirmed hospitalized recovered migrated deceased].freeze

  validates :status, inclusion: { in: STATUSES, message: "%{value} is not one of valid status: #{STATUSES.to_sentence}" }, presence: true
  validates :zone_code, format: { with: %r{\w{2}\/\S+\/\S+\/\S+}, message: "invalid zone format, should be '{country_code}/{state_code}/{district_code}/{city_code}', got %{value}" }

  has_many :taggings, as: :taggable, dependent: :destroy
end
