# frozen_string_literal: true

module V2
  class ZoneCache < ApplicationRecord
    validates :code, :current_actives, :cumulative_infections, :cumulative_recoveries,
              :cumulative_fatalities, :cumulative_tests, :as_of, :start, :stop,
              :population, :area_sq_km, presence: true
    belongs_to :zone, class_name: "::V2::Zone", foreign_key: :code, primary_key: :code, inverse_of: :cache

    def self.index(from:, to:)
      from = to.to_date - 1.day if from.to_date >= to.to_date
      Daru::DateTimeIndex.date_range(start: from.to_date.to_s, end: to.to_date.to_s, freq: "D")
    end

    def self.zero_vector(index:)
      Daru::Vector.new([0] * index.size, index: index)
    end

    def self.vector(index:, time_series:)
      vector = zero_vector(index: index)
      time_series.each do |dt, val|
        vector[dt.to_s] = val if vector.has_index?(dt.to_s)
      end
      vector
    end

    delegate :name, to: :zone

    def chart_index
      index(from: [start, 8.days.ago].min, to: [stop - 1.day, 1.day.ago].min)
    end

    def index(from: nil, to: nil)
      self.class.index(from: from || start, to: to || stop)
    end

    def daily_infections(from: nil, to: nil, idx: nil)
      _ts(:infections, from: from, to: to, idx: idx)
    end

    def daily_recoveries(from: nil, to: nil, idx: nil)
      _ts(:recoveries, from: from, to: to, idx: idx)
    end

    def daily_fatalities(from: nil, to: nil, idx: nil)
      _ts(:fatalities, from: from, to: to, idx: idx)
    end

    def daily_tests(from: nil, to: nil, idx: nil)
      _ts(:tests, from: from, to: to, idx: idx)
    end

    def total_actives(from: nil, to: nil, idx: nil)
      _ts(:actives, from: from, to: to, idx: idx)
    end

    def total_infections(from: nil, to: nil, idx: nil)
      daily_infections(from: from, to: to, idx: idx).cumsum
    end

    def total_recoveries(from: nil, to: nil, idx: nil)
      daily_recoveries(from: from, to: to, idx: idx).cumsum
    end

    def total_fatalities(from: nil, to: nil, idx: nil)
      daily_fatalities(from: from, to: to, idx: idx).cumsum
    end

    def total_tests(from: nil, to: nil, idx: nil)
      daily_tests(from: from, to: to, idx: idx).cumsum
    end

    private

    def _ts(field, from: nil, to: nil, idx: nil)
      idx ||= index(from: from, to: to)
      self.class.vector(index: idx, time_series: public_send(:"ts_#{field}"))
    end
  end
end
