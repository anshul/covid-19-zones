# frozen_string_literal: true

class TimeSeriesPoint < ApplicationRecord
  def self.series(target:, field:, start: Date.parse("Jan 1, 2020"), stop: Time.zone.today)
    TimeSeriesPoint.where(target_code: target.code, target_type: target.type, dated: start..stop).order(:dated).pluck(:dated, field)
  end

  def self.index(start: Date.parse("Jan 1, 2020"), stop: Time.zone.today)
    Daru::DateTimeIndex.date_range(start: start.to_date.to_s, end: stop.to_date.to_s, freq: "D")
  end

  def self.vector(target:, field:, index:)
    vector = Daru::Vector.new([0] * index.size, index: index)
    series(target: target, field: field, start: index.first, stop: index.max).each do |dt, val|
      vector[dt.to_s] = val
    end
    vector
  end

  def zero?
    announced.zero? && recovered.zero? && deceased.zero?
  end
end
