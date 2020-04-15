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

  validates :zone, presence: true

  def run
    valid? &&
      show
  end

  private

  def show
    @result = {
      parent_zone:             decorated_parent_zone,
      sibling_zones:           decorated_sibling_zones,
      per_day_counts:          chart_per_day,
      five_day_moving_average: chart_per_day_sma
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

    sibling_total_case_counts = Patient.where("zone_code like ?", "#{parent_zone&.code || zone.code}/%").group(:zone_code).count
    total_count_extractor = ->(s_zone) { sibling_total_case_counts.filter { |code| code.starts_with?(s_zone.code) }.map { |_, v| v }.sum }

    @decorated_sibling_zones = sibling_zones.map { |z| z.as_json(only: Zone.view_attrs).merge("total_cases" => total_count_extractor.call(z)) }
    @decorated_sibling_zones
  end

  def chart_per_day
    return @chart_per_day if @chart_per_day

    points_hash = Hash[TimeSeriesPoint.where(target_code: zone.code).order(:dated).map { |point| [point.dated, point.announced] }]

    @chart_per_day = (oldest_date..Time.zone.today).map { |date| decorated_point({ dated: date, count: points_hash[date] || 0 }) }
  end

  def chart_per_day_sma
    average_computer = ->(group) { (group.map { |point| point[:y] }.sum / group.count.to_f).round(2) }
    @chart_per_day_sma ||= chart_per_day.in_groups_of(5).select { |group| group.compact.count == group.count }.map do |group|
      { x: group.last[:x], y: average_computer.call(group) }
    end
  end

  def decorated_point(point)
    { x: point[:dated], y: point[:count] }
  end

  def oldest_date
    @oldest_date ||= Patient.where("zone_code like ?", "#{parent_zone.code}%").minimum(:announced_on) || 14.days.ago
  end
end
