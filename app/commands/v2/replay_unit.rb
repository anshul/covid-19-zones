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
      unit = units(fact.entity_slug).tap { |m| m.assign_attributes(**details.slice(*V2::Unit.rw_attribute_names), code: fact.entity_slug) }
      zone = zones(fact.entity_slug).tap { |m| m.assign_attributes(**details.slice(*V2::Zone.rw_attribute_names), code: fact.entity_slug, published_at: fact.happened_at) }
      join_code = "#{unit.code}|#{zone.code}"
      @posts[join_code] = ::V2::Post.new(code: join_code, unit_code: unit.code, zone_code: zone.code)
      Rails.logger.info "Invalid fact: #{fact.as_json}" unless unit.valid? && zone.valid?
      check_validity(zone, fact) && check_validity(unit, fact)
    end

    def replay_zone_published(fact:, **_)
      zone = zones(fact.entity_slug).tap { |m| m.assign_attributes(published_at: fact.happened_at) }
      check_validity zone, fact
    end

    def replay_zone_unpublished(fact:, **_)
      zone = zones(fact.entity_slug).tap { |m| m.assign_attributes(published_at: nil) }
      check_validity zone, fact
    end

    def replay_zone_patched(details:, fact:, **_)
      zone = zones(fact.entity_slug).tap { |m| m.assign_attributes(**details.slice(*V2::Zone.rw_attribute_names), code: fact.entity_slug) }
      (details[:unit_code_changes] || {}).each do |unit_code, is_added|
        join_code = "#{unit_code}|#{zone.code}"
        @posts[join_code] = is_added ? ::V2::Post.new(code: join_code, unit_code: unit_code, zone_code: zone.code) : nil
      end
      check_validity(zone, fact) && check_validity(unit, fact)
    end

    def replay_override_created(details:, fact:, **_)
      replay_override_patched(details: details, fact: fact)
    end

    def replay_override_patched(details:, fact:, **_)
      override = overrides(fact.entity_slug).tap { |m| m.assign_attributes(**details.slice(*V2::Override.rw_attribute_names), code: fact.entity_slug) }
      check_validity(override, fact)
    end

    def replay_override_details_uploaded(details:, fact:, **_)
      override = overrides(fact.entity_slug).tap { |m| m.assign_attributes(override_details: details[:override_details], code: fact.entity_slug) }
      check_validity override, fact
    end
  end
end
