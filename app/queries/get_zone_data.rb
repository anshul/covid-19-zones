# frozen_string_literal: true

class GetZoneData < BaseQuery
  attr_reader :code, :log
  def initialize(code:, log: nil)
    @code = code
    @result = {}
    @log = log || lambda { |color, msg, return_value:|
      puts_colored color.to_sym, "#{format('%.3f', t).rjust(5)}s - #{msg}"
      return_value
    }
  end

  validates :zone, :cache, presence: true

  def run
    valid? &&
      show
  end

  private

  def show
    @result = zone.as_typical_json.merge(cache.as_typical_json).merge(
      debug_link:    "/v2/zone_computations/#{zone.cache.id}",
      confirmed:     cache.cumulative_infections,
      active:        cache.current_actives,
      recovered:     cache.cumulative_recoveries,
      deceased:      cache.cumulative_fatalities,
      parent_zone:   parent_zone.as_typical_json.merge(cache.as_typical_json),
      related_zones: related_zones.map { |z| z.as_typical_json.merge(z.cache.as_json(only: %i[name cumulative_infections current_actives cumulative_fatalities cumulative_recoveries])) }
    ).deep_transform_keys { |k| k.to_s.camelize :lower }
  end

  def zone
    @zone ||= ::V2::Zone.find_by(code: code)
  end

  def cache
    @cache ||= zone&.cache
  end

  def parent_zone
    @parent_zone ||= zone.parent || zone
  end

  def related_zones
    return @related_zones if @related_zones

    @related_zones = zone.children
    @related_zones = parent_zone.children if @related_zones.empty?
    @related_zones = @related_zones.sort_by { |z| - z.cache.cumulative_infections }
    @related_zones
  end
end
