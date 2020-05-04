# frozen_string_literal: true

module V2
  class SeedOverrides < BaseCommand
    def self.perform_task
      new.call_with_transaction
    end

    def run
      create_overrides &&
        log(" - v2 overrides: We have #{::V2::Override.count} overrides.") ||
        puts_red("Failed: #{error_message}")
    end

    def create_overrides
      units.all? do |unit|
        next true if unit.override.present?

        cmd = ::V2::CreateOverride.new(unit_code: unit.code, maintainer: User["bot"].email)
        cmd.call(errors: errors)
      end
    end

    def units
      @units ||= ::V2::Unit.where(category: ::V2::Unit::OVERRIDABLE_CATEGORIES)
    end
  end
end
