# frozen_string_literal: true

class GetZoneData < BaseQuery
  attr_reader :slug, :log
  def initialize(slug:, log: nil)
    @slug = slug
    @result = {}
    @log = log || ->(color, msg, return_value:) { puts_colored color.to_sym, "#{format('%.3f', t).rjust(5)}s - #{msg}"; return_value }
  end

  validates :zone, presence: true

  def run
    valid? &&
      show
  end

  private

  def show
    @result = {
      parent_zone:              decorated_parent_zone,
      sibling_zones:            decorated_sibling_zones,
      per_day_counts:           chart_per_day,
      three_day_moving_average: chart_per_day_sma
    }.deep_transform_keys { |k| k.to_s.camelize :lower }
  end

  def zone
    @zone ||= Zone.find_by(slug: slug)
  end

  def parent_zone
    @parent_zone ||= zone.parent
  end

  def sibling_zones
    @sibling_zones ||= parent_zone&.children || [zone]
  end

  def decorated_parent_zone
    return @decorated_parent_zone if @decorated_parent_zone

    @decorated_parent_zone = parent_zone&.as_json(only: Zone.view_attrs)
    @decorated_parent_zone
  end

  def decorated_sibling_zones
    return @decorated_sibling_zones if @decorated_sibling_zones

    @decorated_sibling_zones = sibling_zones.map { |z| z.as_json(only: Zone.view_attrs) }
    @decorated_sibling_zones
  end

  def oldest_date
    @oldest_date ||= Patient.where("zone_code like ?", "#{parent_zone.code}%").minimum(:announced_on) || 14.days.ago
  end
end
