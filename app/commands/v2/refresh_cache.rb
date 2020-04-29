# frozen_string_literal: true

module V2
  class RefreshCache < ::BaseCommand
    def self.perform_task
      log "Refreshing #{::V2::Zone.count} zones"
      ::V2::Zone.in_batches.all? do |rel|
        rel.pluck(:code).all? do |code|
          cmd = new(zone_code: code)
          out = cmd.call
          out ? log("  * cache updated - #{code}", color: :green) : log(" A * Cache failed for #{code.inspect}: #{cmd.error_message}", color: :red)
          out
        end
      end
    end
    attr_reader :zone_code
    def initialize(zone_code:)
      @zone_code = zone_code.to_s
    end

    def run
      cache.assign_attributes(
        start:                 start,
        stop:                  stop,
        current_actives:       vec(:actives).entries.last,
        cumulative_infections: vec(:infections).sum,
        cumulative_recoveries: vec(:recoveries).sum,
        cumulative_fatalities: vec(:fatalities).sum,
        cumulative_tests:      vec(:tests).sum,
        as_of:                 as_of || t_start,
        attributions_md:       attributions_md,
        unit_codes:            zone.units.map(&:code),
        ts_actives:            ts(:actives),
        ts_infections:         ts(:infections),
        ts_recoveries:         ts(:recoveries),
        ts_fatalities:         ts(:fatalities),
        ts_tests:              ts(:tests),
        cached_at:             t_start,
        streams:               streams_by_type,
        population:            zone.units.sum(&:population),
        area_sq_km:            zone.units.sum(&:area_sq_km)
      )
      cache.save || add_error(cache.error_message)
    end

    def streams_by_type
      %i[infections recoveries fatalities tests].index_with { |f| streams(f).transform_values { |s| s ? { code: s.code, snapshot_id: s.snapshot_id, origin_code: s.origin_code } : nil } }
    end

    def index
      @index ||= ::V2::Stream.index(start: start, stop: stop)
    end

    def attributions_md
      @attributions_md ||= CATEGORIES.keys.map { |k| streams(k).values.compact.map(&:attribution_md) }.flatten.compact.sort.uniq
    end

    def as_of
      @as_of ||= CATEGORIES.keys.map { |k| streams(k).values.compact.map(&:downloaded_at).compact.max }.compact.max || t_start
    end

    def start
      @start ||= (CATEGORIES.keys.map { |k| streams(k).values.compact.map(&:min_date).compact.min }.compact.min || t_start).to_date
    end

    def stop
      @stop ||= (CATEGORIES.keys.map { |k| streams(k).values.compact.map(&:max_date).compact.max }.compact.max || t_start).to_date + 1.day
    end

    CATEGORIES = {
      infections: %w[announce infections],
      recoveries: %w[recovery recoveries],
      fatalities: %w[fatality fatalities],
      tests:      %w[testing]
    }.freeze

    def ts(type)
      v = vec(type)
      Hash[
        index.entries.map do |dt|
          val = v[dt.to_date.to_s].to_i
          val.zero? ? nil : [dt.to_date.to_s, val]
        end.compact
      ]
    end

    def vec(type)
      @vec ||= {}
      @vec[type.to_sym] ||= vec(:infections).cumsum - vec(:recoveries).cumsum - vec(:fatalities).cumsum if type.to_sym == :actives
      @vec[type.to_sym] ||= vectors(type).values.compact.empty? ? ::V2::Stream.zero_vector(index: index) : vectors(type).values.compact.sum
    end

    def vectors(type)
      @vectors ||= {}
      @vectors[type.to_sym] ||= streams(type).transform_values { |v| v&.vector(idx: index) }
    end

    def streams(type)
      @streams ||= {}
      @streams[type.to_sym] ||= zone.units.index_with { |u| u.streams.select { |s| CATEGORIES[type.to_sym].include?(s.category) }.min_by(&:priority) }.transform_keys(&:code)
    end

    def cache
      @cache ||= ::V2::ZoneCache.find_by(code: zone.code) || ::V2::ZoneCache.new(code: zone.code)
    end

    def zone
      @zone ||= ::V2::Zone.includes(units: { streams: :snapshot }).readonly.find_by(code: zone_code)
    end
  end
end
