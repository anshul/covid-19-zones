# frozen_string_literal: true

module V2
  class ReplayUnit < ::V2::ReplayBase
    def self.perform_replay_all_task
      log "Replaying #{::V2::Fact.where(entity_type: 'unit').distinct(:entity_slug).count} units"
      ::V2::Fact.where(entity_type: "unit").distinct(:entity_slug).in_batches.all? do |rel|
        rel.pluck(:entity_slug).all? do |slug|
          cmd = new(entity_slug: slug)
          out = cmd.call
          out ? log("  * Replayed #{slug}", color: :green) : log(" A * Replay failed for #{slug.inspect}: #{cmd.error_message}", color: :red)
          out
        end
      end
    end

    def replay_unit_patched(details:, fact:, **_)
      unit = units(details[:code]).tap { |m| m.assign_attributes(**details.slice(*V2::Unit.rw_attribute_names)) }
      zone = zones(details[:code]).tap { |m| m.assign_attributes(**details.slice(*V2::Zone.rw_attribute_names), published_at: fact.happened_at) }
      join_code = "#{unit.code}|#{zone.code}"
      @posts[join_code] = ::V2::Post.new(code: join_code, unit_code: unit.code, zone_code: zone.code)
      Rails.logger.info "Invalid fact: #{fact.as_json}" unless unit.valid? && zone.valid?
      return add_error("Invalid unit: #{unit.error_message}") unless unit.valid?
      return add_error("Invalid zone: #{zone.error_message}") unless zone.valid?

      true
    end

    def replay_zone_published(fact:, **_)
      zone = zones(fact.entity_slug)
      zone.published_at = fact.happened_at

      true
    end

    def replay_zone_unpublished(fact:, **_)
      zone = zones(fact.entity_slug)
      zone.published_at = nil

      true
    end

    def replay_override_created(details:, fact:, **_)
      override = overrides(fact.entity_slug)
      override.assign_attributes(**details.slice(*::V2::Override.rw_attribute_names), code: fact.entity_slug)

      true
    end

    def replay_override_details_uploaded(details:, fact:, **_)
      override = overrides(fact.entity_slug)
      override.assign_attributes(override_details: details[:override_details])

      true
    end
  end
end
