# frozen_string_literal: true

require "digest"

class Recompute < BaseCommand
  attr_reader :response, :raw_patients, :unknown_districts, :log

  def initialize(log: nil)
    @log = log || lambda { |color, msg, return_value = true|
      puts_colored color.to_sym, "#{format('%.3f', t).rjust(5)}s - #{msg}"
      return_value
    }
  end

  def self.perform_task
    new.call_with_transaction
  end

  def run
    log.call(:blue, "Computing new time series data")
    points = []
    Zone.find_each do |zone|
      (oldest_date..newest_date).each do |dt|
        point = data_point(zone, dt)
        points << point unless point.zero?
      end
    end
    TimeSeriesPoint.delete_all
    result = TimeSeriesPoint.import!(points, on_duplicate_key_ignore: true, validate: false, batch_size: 500)
    log.call(:green, "Created #{TimeSeriesPoint.count} data points.", result)
  end

  def data_point(zone, date)
    TimeSeriesPoint.new(
      dated:       date,
      target_code: zone.code,
      target_type: zone.class.name,
      population:  zone.pop,
      area_sq_km:  zone.area,
      density:     zone.density,
      announced:   announced_by_date_and_zone[date].map { |k, v| k.starts_with?(zone.code) ? v : 0 }.sum,
      recovered:   recovered_by_date_and_zone[date].map { |k, v| k.starts_with?(zone.code) ? v : 0 }.sum,
      deceased:    deceased_by_date_and_zone[date].map { |k, v| k.starts_with?(zone.code) ? v : 0 }.sum
    )
  end

  def announced_by_date_and_zone
    @announced_by_date_and_zone ||= get_grouped_data(Patient.group(:announced_on, :zone_code).count)
  end

  def recovered_by_date_and_zone
    @recovered_by_date_and_zone ||= get_grouped_data(Patient.where(status: "recovered").group(:status_changed_on, :zone_code).count)
  end

  def deceased_by_date_and_zone
    @deceased_by_date_and_zone ||= get_grouped_data(Patient.where(status: "deceased").group(:status_changed_on, :zone_code).count)
  end

  def get_grouped_data(group_query)
    out = Hash.new { |h, k| h[k] = Hash.new(0) }
    group_query.each do |arr, count|
      date, zone = arr
      out[date][zone] = count
    end
    out
  end

  def oldest_date
    @oldest_date ||= ::Patient.minimum(:announced_on) || 14.days.ago
  end

  def newest_date
    @newest_date ||= Time.zone.today
  end
end
