# frozen_string_literal: true

module V2
  class Stream < ApplicationRecord
    CATEGORIES = %w[announce active recovery fatality testing].freeze
    validates :category, inclusion: { in: CATEGORIES }
    validate :check_format_of_time_series

    validates :code, :unit_code, :origin_code, presence: true
    validates :time_series, :dated, :snapshot_id, presence: true
    belongs_to :snapshot, class_name: "V2::Snapshot"

    def check_format_of_time_series
      return true if time_series.nil?
      return ts_error("can't be a #{time_series.class}") unless time_series.is_a?(Hash)
      return ts_error("all time series keys must be yyyy-mm-dd") unless time_series.keys.all? { |k| k =~ /\A\d\d\d\d\-\d\d\-\d\d\z/ }
      return ts_error("all time series values must be numeric") unless time_series.values.all? { |v| v.is_a?(Numeric) }

      true
    end

    def self.index(start: nil, stop: nil)
      Daru::DateTimeIndex.date_range(start: start.to_date.to_s, end: stop.to_date.to_s, freq: "D")
    end

    def self.vector(target:, field:, index:)
      vector = Daru::Vector.new([0] * index.size, index: index)
      series(target: target, field: field, start: index.first, stop: index.max).each do |dt, val|
        vector[dt.to_s] = val
      end
      vector
    end

    private

    def ts_error(msg)
      errors.add(:time_series, msg)
      false
    end
  end
end
