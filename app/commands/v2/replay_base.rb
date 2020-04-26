# frozen_string_literal: true

module V2
  class ReplayBase < ::BaseCommand
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
        fill_search_keys &&
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
        models.empty? ? true : import(klass, models, on_duplicate_key_update: klass.on_duplicate_key_options, batch_size: 500)
      end
    end

    def fill_search_keys
      @zones.transform_values do |zone|
        search_candidates = [zone.name] + (zone.aliases || [])
        zone.search_key = search_candidates.map(&:downcase).join(";")

        zone
      end
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
