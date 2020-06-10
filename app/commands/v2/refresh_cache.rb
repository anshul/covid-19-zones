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
        current_hospitals:     vec(:hospitals).entries.reject(&:zero?).last || 0,
        current_hospital_beds: vec(:hospital_beds).entries.reject(&:zero?).last || 0,
        current_icu_beds:      vec(:icu_beds).entries.reject(&:zero?).last || 0,

        cumulative_infections: vec(:infections).sum,
        cumulative_recoveries: vec(:recoveries).sum,
        cumulative_fatalities: vec(:fatalities).sum,
        cumulative_tests:      vec(:tests).sum,
        as_of:                 as_of || t_start,
        attributions_md:       attributions_md,
        unit_codes:            zone.units.map(&:code),
        ts_actives:            ts(:actives),
        ts_hospitals:          ts(:hospitals),
        ts_hospital_beds:      ts(:hospital_beds),
        ts_icu_beds:           ts(:icu_beds),
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
      @start ||= (CATEGORIES.keys.map do |k|
        [override_dates(k).min, stream_min_dates(k).min].compact.min
      end.compact.min || t_start).to_date
    end

    def stop
      @stop ||= (CATEGORIES.keys.map do |k|
        [override_dates(k).max, stream_max_dates(k).max].compact.max
      end.compact.max || t_start).to_date + 1.day
    end

    CATEGORIES = {
      infections:    %w[announce infections],
      recoveries:    %w[recovery recoveries],
      fatalities:    %w[fatality fatalities],
      tests:         %w[testing],
      hospitals:     %w[hospitals],
      hospital_beds: %w[hospital_beds],
      icu_beds:      %w[icu_beds]
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
      @vectors[type.to_sym] ||= streams(type).transform_values { |v| v&.vector(idx: index).presence || ::V2::Stream.zero_vector(index: index) }.tap do |vecs|
        vecs.keys.map { |unit_code| overrides(type)[unit_code]&.each { |row| vecs[unit_code][row["date"]] = row["value"] } }
      end
    end

    def streams(type)
      @streams ||= {}
      @streams[type.to_sym] ||= zone.units.index_with { |u| u.streams.select { |s| CATEGORIES[type.to_sym].include?(s.category) }.min_by(&:priority) }.transform_keys(&:code)
    end

    def stream_min_dates(type)
      streams(type).values.compact.map(&:min_date).compact
    end

    def stream_max_dates(type)
      streams(type).values.compact.map(&:max_date).compact
    end

    def overrides(type)
      @overrides ||= {}
      @overrides[type.to_sym] ||= zone.units.index_with do |u|
        overrides = [u.override, u.parent&.override].compact
        overrides.map { |override| override.override_details.select { |ov| ov["unit_code"] == u.code && CATEGORIES[type.to_sym].include?(ov["category"]) } }
                 .flatten.uniq { |row| row["date"] }
      end.transform_keys(&:code)
    end

    def override_dates(type)
      overrides(type).values.compact.map { |ovs| ovs.map { |row| row["date"] } }.flatten
    end

    def cache
      @cache ||= ::V2::ZoneCache.find_by(code: zone.code) || ::V2::ZoneCache.new(code: zone.code)
    end

    def zone
      @zone ||= ::V2::Zone.includes(units: :streams).readonly.find_by(code: zone_code)
    end
  end
end
