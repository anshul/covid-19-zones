# frozen_string_literal: true

module V2
  class ReplayUnit < ::V2::ReplayBase

    def replay_unit_patched(details:, fact:, **_)
      unit = units(details[:code]).tap { |m| m.assign_attributes(**details.slice(*V2::Unit.rw_attribute_names)) }
      zone = zones(details[:code]).tap { |m| m.assign_attributes(**details.slice(*V2::Zone.rw_attribute_names)) }
      join_code = "#{unit.code}|#{zone.code}"
      @posts[join_code] = ::V2::Post.new(code: join_code, unit_code: unit.code, zone_code: zone.code)
      Rails.logger.info "Invalid fact: #{fact.as_json}" unless unit.valid? && zone.valid?
      return add_error("Invalid unit: #{unit.error_message}") unless unit.valid?
      return add_error("Invalid zone: #{zone.error_message}") unless zone.valid?

      true
    end

  end
end
