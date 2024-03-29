# frozen_string_literal: true

class Patient < ApplicationRecord
  validates :code, :external_code, :source, :zone_code, :announced_on, presence: true
  validates :zone_code, format: %r{\A[a-z\-]+/[a-z\-]+/[a-z\-]+/[a-z0-9\-]+/[a-z0-9\-]+\z}

  STATUSES = %w[unknown confirmed hospitalized recovered migrated deceased].freeze

  def self.slug_for(uid)
    "covid19-india-#{uid}"
  end

  def self.code_for(uid)
    "c19-in-#{uid}"
  end

  validates :status, inclusion: { in: STATUSES, message: "%{value} is not one of valid status: #{STATUSES.to_sentence}" }, presence: true
  validates :zone_code, format: { with: %r{\w{2}\/\S+\/\S+\/\S+}, message: "invalid zone format, should be '{country_code}/{state_code}/{district_code}/{city_code}', got %{value}" }

  has_many :taggings, as: :taggable, dependent: :destroy
end
