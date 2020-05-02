# frozen_string_literal: true

class GetZoneData < BaseQuery
  attr_reader :slug, :log
  def initialize(slug:, log: nil)
    @slug = slug
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
    @result = {
      y_max:         50_000,
      zone:          zone.name,
      confirmed:     {
        total_count:             cache.cumulative_infections,
        per_day_counts:          [],
        five_day_moving_average: []
      },
      active:        {
        total_count:             cache.current_actives,
        per_day_counts:          [],
        five_day_moving_average: []
      },
      recovered:     {
        total_count:             cache.cumulative_recoveries,
        per_day_counts:          [],
        five_day_moving_average: []
      },
      deceased:      {
        total_count:             cache.cumulative_fatalities,
        per_day_counts:          [],
        five_day_moving_average: []
      },
      parent_zone:   parent_zone.as_typical_json.merge(cache.as_typical_json),
      sibling_zones: sibling_zones.map { |z| z.as_typical_json.merge(z.cache.as_typical_json) }
    }.deep_transform_keys { |k| k.to_s.camelize :lower }
  end

  def zone
    @zone ||= ::V2::Zone.find_by(code: slug)
  end

  def cache
    @cache ||= zone&.cache
  end

  def parent_zone
    @parent_zone ||= zone.parent || zone
  end

  def sibling_zones
    @sibling_zones ||= parent_zone.children
  end
end
