# frozen_string_literal: true

module V2
  class Snapshot < ApplicationRecord
    validates :origin_code, :signature, :data, :downloaded_at, presence: true
    has_many :streams, dependent: :delete_all
    belongs_to :origin, class_name: "V2::Origin", foreign_key: :origin_code, primary_key: :code, inverse_of: :snapshots

    def rows
      return data["deaths_recoveries"].filter { |row| row["date"].present? } if origin_code == "covid19-india-deaths-and-recoveries"
      return data["raw_data"].filter { |row| row["dateannounced"].present? } if origin_code == "covid19-india-raw-data"

      []
    end

    INTERESTING_KEYS = {
      "covid19-india-raw-data" => [%w[statecode], %w[dateannounced], %w[detectedcity detecteddistrict], %w[detecteddistrict detectedstate], %w[detectedstate statecode]].freeze
    }.freeze

    def interesting_keys
      @interesting_keys ||= INTERESTING_KEYS[origin_code] || []
    end

    def other_keys
      return [] if rows.empty?

      @other_keys ||= rows.first.keys.map { |k| [k] } - interesting_keys
    end

    def stats
      return @stats if @stats
      return {} if rows.empty?

      @stats = {}
      (interesting_keys + other_keys).each do |keys|
        @stats[keys.join(";")] = rows.map { |r| keys.map { |k| r[k].to_s.parameterize }.join(";") }.tally.to_a.sort_by(&:last).reverse.map { |k, n| "#{k} (#{n})" }
      end
      @stats
    end
  end
end
