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
      parent_zone:           decorated_parent_zone,
      sibling_zones:         decorated_sibling_zones,
      series_announced:      chart_announced,
      series_announced_sma5: chart_announced_sma5
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

  def chart_announced
    @chart_announced ||= dates.map { |dt| { x: dt, y: announced_vector[dt] } }
  end

  def chart_announced_sma5
    @chart_announced_sma5 ||= dates.map { |dt| { x: dt, y: announced_vector_sma5[dt] } }
  end

  def index
    @index ||= TimeSeriesPoint.index(start: oldest_date, stop: 1.day.ago)
  end

  def announced_vector
    @announced_vector ||= TimeSeriesPoint.vector(target: zone, field: "announced", index: index)
  end

  def recovered_vector
    @recovered_vector ||= TimeSeriesPoint.vector(target: zone, field: "recovered", index: index)
  end

  def deceased_vector
    @deceased_vector ||= TimeSeriesPoint.vector(target: zone, field: "deceased", index: index)
  end

  def dates
    @dates ||= index.entries.map(&:to_date).map(&:to_s)
  end

  def announced_vector_sma5
    @announced_vector_sma5 ||= announced_vector.rolling_mean(5)
  end

  def oldest_date
    @oldest_date ||= Patient.where("zone_code like ?", "#{parent_zone&.code || zone.code}%").minimum(:announced_on) || 14.days.ago
  end
end
