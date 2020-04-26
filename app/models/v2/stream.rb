# frozen_string_literal: true

module V2
  class Stream < ApplicationRecord
    CATEGORIES = %w[infections recoveries fatalities tests].freeze
    validates :category, inclusion: { in: CATEGORIES }
    validate :check_format_of_time_series

    validates :code, :unit_code, :origin_code, presence: true
    validates :time_series, :dated, :snapshot_id, presence: true
    belongs_to :snapshot, class_name: "V2::Snapshot"
    belongs_to :unit, class_name: "V2::Unit", foreign_key: :unit_code, primary_key: :code, inverse_of: :streams
    belongs_to :origin, class_name: "V2::Origin", foreign_key: :origin_code, primary_key: :code, inverse_of: :streams

    def name
      "#{origin.name} (#{category}) - #{unit.name}"
    end

    def check_format_of_time_series
      return true if time_series.nil?
      return ts_error("can't be a #{time_series.class}") unless time_series.is_a?(Hash)
      return ts_error("all time series keys must be yyyy-mm-dd") unless time_series.keys.all? { |k| k =~ /\A\d\d\d\d\-\d\d\-\d\d\z/ }
      return ts_error("all time series values must be numeric") unless time_series.values.all? { |v| v.is_a?(Numeric) }

      true
    end

    def refresh_meta!
      assign_attributes(
        min_count:        time_series.values.min,
        max_count:        time_series.values.max,
        cumulative_count: time_series.values.sum,
        min_date:         time_series.keys.min,
        max_date:         time_series.keys.max
      )
    end

    def self.index(start:, stop:)
      Daru::DateTimeIndex.date_range(start: start.to_date.to_s, end: stop.to_date.to_s, freq: "D")
    end

    def self.zero_vector(index:)
      Daru::Vector.new([0] * index.size, index: index)
    end

    def self.vector(index:, time_series:)
      vector = zero_vector(index: index)
      time_series.each do |dt, val|
        vector[dt.to_s] = val
      end
      vector
    end

    def index(start: nil, stop: nil)
      start ||= min_date
      stop ||= max_date
      self.class.index(start: start, stop: stop)
    end

    def vector(start: nil, stop: nil, idx: nil)
      idx ||= index(start: start, stop: stop)
      self.class.vector(index: idx, time_series: time_series)
    end

    private

    def ts_error(msg)
      errors.add(:time_series, msg)
      false
    end
  end
end
