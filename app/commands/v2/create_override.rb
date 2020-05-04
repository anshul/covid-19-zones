# frozen_string_literal: true

module V2
  class CreateOverride < ::BaseCommand
    attr_reader :unit_code, :unit, :maintainer
    def initialize(unit_code:, maintainer:)
      @unit_code = unit_code
      @maintainer = maintainer
      @unit = ::V2::Unit.find_by(code: unit_code)
    end

    def run
      return add_error "Unit does not exist" if unit.blank?
      return add_error "Override already exists" if unit.override.present?

      record_fact(:override_created, entity_type: :unit, entity_slug: unit_code, details: { maintainer: maintainer })
    end
  end
end
