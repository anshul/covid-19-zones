# frozen_string_literal: true

module V2
  class ReplayUnit < ::BaseCommand
    attr_reader :entity_slug, :facts
    def initialize(entity_slug:)
      @entity_slug = entity_slug.to_s
      @facts = ::V2::Fact.where(entity_type: "unit", entity_slug: @entity_slug).order(:sequence)
      @units = {}
      @zones = {}
      @posts = {}
    end

    def run
      replay_all &&
        delete({ ::V2::Unit => @units, ::V2::Zone => @zones, ::V2::Post => @posts }) &&
        upsert({ ::V2::Unit => @units, ::V2::Zone => @zones, ::V2::Post => @posts })
    end

    def replay_all
      facts.all? do |fact|
        send(:"replay_#{fact.fact_type}", fact: fact, details: fact.details.stringify_keys)
      end
    end

    def delete(targets)
      targets.all? do |klass, h|
        deletable_codes = h.keys.reject { |k| h[k] }
        deletable_codes.empty? ? true : klass.where(code: deletable_codes).delete_all
      end
    end

    def upsert(targets)
      targets.all? do |klass, h|
        models = h.values.select { |k| k }
        models.empty? ? true : klass.import(models, on_duplicate_key_update: klass.on_duplicate_key_options, batch_size: 500)
      end
    end

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

    def units(key)
      _model_value(@units, ::V2::Unit, key)
    end

    def zones(key)
      _model_value(@zones, ::V2::Zone, key)
    end

    def _model_value(hash, klass, key)
      hash[key] ||= klass.default_model
    end
  end
end
