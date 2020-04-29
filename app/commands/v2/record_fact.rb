# frozen_string_literal: true

module V2
  class RecordFact < ::BaseCommand
    VALID_KEYS = {
      unit_patched:     ((::V2::Unit.attribute_names.map(&:to_s) + ::V2::Zone.attribute_names).map(&:to_s) - %w[id created_at updated_at]).map(&:to_sym).freeze,
      zone_published:   %i[published_by],
      zone_unpublished: %i[unpublished_by],
      override_created: (::V2::Override.attribute_names.map(&:to_s) - %w[id created_at updated_at]).map(&:to_sym).freeze
    }.freeze
    SIGNATURE_KEYS = {}.freeze

    attr_reader :details, :entity_type, :entity_slug, :fact_type, :repeatable
    def initialize(details:, entity_type:, entity_slug:, fact_type:, repeatable: false)
      @details = details.dup.symbolize_keys
      @fact_type = fact_type.to_sym
      raise ArgumentError, "Unknown fact_type #{@fact_type.inspect}" unless VALID_KEYS.key?(@fact_type)

      @repeatable = repeatable
      @entity_slug = entity_slug.to_s
      @entity_type = entity_type.to_s
      extra_keys = details.keys - VALID_KEYS[fact_type.to_sym]
      raise ArgumentError, "Unknown details #{extra_keys.map(&:inspect).to_sentence}" unless extra_keys.empty?
    end

    def run
      return true if !repeatable & fact_repeats?
    end

    private

    def fact_repeats?
      return true if previous_fact_signature == fact.signature

      return add_error(fact.errors.full_messages.to_sentence.gsub(";,", ";").gsub(".,", ",")) unless fact.save

      replay_all
    end

    def replay_all
      replay_klass_name = "v2/replay_#{entity_type}".classify
      replay_klass = replay_klass_name.safe_constantize
      return add_error("Replayer #{replay_klass_name} not found.") unless replay_klass

      cmd = replay_klass.new(entity_slug: fact.entity_slug)
      cmd.call || add_error(cmd.error_message)
    end

    def fact
      return @fact if @fact

      @fact = ::V2::Fact.new(
        entity_slug: entity_slug,
        entity_type: entity_type,
        fact_type:   fact_type.to_s,
        details:     details,
        signature:   Digest::MD5.hexdigest(details.slice(*(SIGNATURE_KEYS[fact_type] || VALID_KEYS[fact_type])).to_a.sort.to_json),
        happened_at: t_start
      )
      @fact.sequence = ::V2::Fact.where(entity_slug: fact.entity_slug, entity_type: fact.entity_type).count + 1
      @fact
    end

    def previous_fact_signature
      @previous_fact_signature ||= ::V2::Fact.where(entity_slug: fact.entity_slug, entity_type: fact.entity_type, fact_type: fact.fact_type).order(sequence: :desc).limit(1).pluck(:signature)
    end
  end
end
