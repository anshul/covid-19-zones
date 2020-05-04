# frozen_string_literal: true

module V2
  class Override < ApplicationRecord
    validates :code, presence: true
    validate :check_format_of_override_details

    OVERRIDE_KEYS = %w[unit_code category date value].freeze
    def check_format_of_override_details
      return true if override_details.blank?
      return od_error("all rows must have keys #{OVERRIDE_KEYS.to_sentence}") unless override_details.all? { |details| details.keys.sort == OVERRIDE_KEYS.sort }
      return od_error("all categories must be one of #{::V2::Stream::CATEGORIES.to_sentence}") unless override_details.all? { |details| ::V2::Stream::CATEGORIES.include?(details["category"]) }

      true
    end

    def overridable_units
      unit.overridable? ? [unit] + unit.children : []
    end

    def od_error(msg)
      errors.add(:override_details, msg)
      false
    end

    belongs_to :unit, class_name: "V2::Unit", foreign_key: :code, primary_key: :code, inverse_of: :override
  end
end
