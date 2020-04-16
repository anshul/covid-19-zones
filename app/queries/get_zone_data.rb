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
      y_max:         [announced_vector.max, announced_vector_sma5.max].max,
      zone:          zone.name,
      confirmed:     {
        total_count:             total_cases,
        per_day_counts:          chart_confirmed,
        five_day_moving_average: chart_confirmed_sma5
      },
      active:        {
        total_count:             total_active_cases,
        per_day_counts:          chart_announced,
        five_day_moving_average: chart_announced_sma5
      },
      recovered:     {
        total_count:             total_recovered,
        per_day_counts:          chart_recovered,
        five_day_moving_average: chart_recovered_sma5
      },
      deceased:      {
        total_count:             total_deceased,
        per_day_counts:          chart_deceased,
        five_day_moving_average: chart_deceased_sma5
      },
      parent_zone:   decorated_parent_zone,
      sibling_zones: decorated_sibling_zones
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

  def total_cases
    @total_cases ||= chart_announced.map { |d| d[:y] }.sum.to_i
  end

  def total_recovered
    @total_recovered ||= recovered_vector.sum.to_i
  end

  def total_deceased
    @total_deceased ||= deceased_vector.sum.to_i
  end

  def total_active_cases
    @total_active_cases ||= (announced_vector.sum - total_recovered - total_deceased).to_i
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
    sibling_active_case_counts = Patient.where("zone_code like ?", "#{parent_zone&.code || zone.code}/%").where.not(status: %w[recovered deceased]).group(:zone_code).count
    total_active_count_extractor = ->(s_zone) { sibling_active_case_counts.filter { |code| code.starts_with?(s_zone.code) }.map { |_, v| v }.sum }
    sibling_recovered_case_counts = Patient.where("zone_code like ?", "#{parent_zone&.code || zone.code}/%").where(status: "recovered").group(:zone_code).count
    total_recovered_count_extractor = ->(s_zone) { sibling_recovered_case_counts.filter { |code| code.starts_with?(s_zone.code) }.map { |_, v| v }.sum }
    sibling_deceased_case_counts = Patient.where("zone_code like ?", "#{parent_zone&.code || zone.code}/%").where(status: "deceased").group(:zone_code).count
    total_deceased_count_extractor = ->(s_zone) { sibling_recovered_case_counts.filter { |code| code.starts_with?(s_zone.code) }.map { |_, v| v }.sum }

    @decorated_sibling_zones = sibling_zones.map do |z|
      z.as_json(only: Zone.view_attrs).merge({
                                               "total_cases"     => total_count_extractor.call(z),
                                               "total_active"    => total_active_count_extractor.call(z),
                                               "total_recovered" => total_recovered_count_extractor.call(z),
                                               "total_deceased"  => total_deceased_count_extractor.call(z)
                                             })
    end
    @decorated_sibling_zones
  end

  def chart_confirmed
    @chart_confirmed ||= dates.map { |dt| { x: dt, y: announced_vector[dt] } }
  end

  def chart_confirmed_sma5
    @chart_confirmed_sma5 ||= dates.map { |dt| { x: dt, y: announced_vector_sma5[dt] } }
  end

  def chart_announced
    @chart_announced ||= dates.map { |dt| { x: dt, y: (announced_vector[dt].to_i - recovered_vector[dt].to_i - deceased_vector[dt].to_i) } }
  end

  def chart_announced_sma5
    @chart_announced_sma5 ||= dates.map { |dt| { x: dt, y: (announced_vector_sma5[dt].to_i - recovered_vector_sma5[dt].to_i - deceased_vector_sma5[dt].to_i) } }
  end

  def chart_recovered
    @chart_recovered ||= dates.map { |dt| { x: dt, y: recovered_vector[dt] } }
  end

  def chart_recovered_sma5
    @chart_recovered_sma5 ||= dates.map { |dt| { x: dt, y: recovered_vector_sma5[dt] } }
  end

  def chart_deceased
    @chart_deceased ||= dates.map { |dt| { x: dt, y: deceased_vector[dt] } }
  end

  def chart_deceased_sma5
    @chart_deceased_sma5 ||= dates.map { |dt| { x: dt, y: deceased_vector_sma5[dt] } }
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

  def recovered_vector_sma5
    @recovered_vector_sma5 ||= recovered_vector.rolling_mean(5)
  end

  def deceased_vector_sma5
    @deceased_vector_sma5 ||= deceased_vector.rolling_mean(5)
  end

  def oldest_date
    @oldest_date ||= Patient.where("zone_code like ?", "#{parent_zone.code || zone.code}%").minimum(:announced_on) || 14.days.ago
  end
end
