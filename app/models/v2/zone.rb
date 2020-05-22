# frozen_string_literal: true

module V2
  class Zone < ApplicationRecord
    validates :code, :name, presence: true
    alias_attribute :slug, :code
    alias_attribute :parent_zone, :parent

    FIELDS = %i[cumulative_infections cumulative_recoveries cumulative_fatalities cumulative_tests current_actives].freeze

    CATEGORIES = %w[country state district city ward].freeze
    validates :category, inclusion: { in: CATEGORIES }

    belongs_to :parent, class_name: "::V2::Zone", foreign_key: "parent_code", primary_key: "code", inverse_of: :children, optional: true
    has_many :children, class_name: "::V2::Zone", foreign_key: "parent_code", primary_key: "code", inverse_of: :parent, dependent: :delete_all
    belongs_to :owner, class_name: "::User", foreign_key: "maintainer", primary_key: "email", inverse_of: :zones
    has_many :posts, class_name: "V2::Post", dependent: :delete_all, foreign_key: "zone_code", primary_key: "code", inverse_of: :zone
    has_many :units, through: :posts
    has_one :cache, class_name: "::V2::ZoneCache", foreign_key: :code, primary_key: :code, inverse_of: :zone, dependent: :delete

    delegate :population, :population_year, :area_sq_km, :f_population, :f_est_population, :f_population_year, :f_est_population_year, :f_area, :as_of, :f_as_of, :start, :stop, :attribution_md, :cached_at, to: :cache
    delegate :current_actives, :cumulative_infections, :cumulative_fatalities, :cumulative_recoveries, :cumulative_tests, to: :cache
    delegate :per_million_actives, :per_million_fatalities, :per_million_infections, :per_million_recoveries, :per_million_tests, to: :cache
    delegate :chart, :unit_codes, to: :cache

    def p_category
      category.pluralize
    end

    def related
      return @related_zones if @related_zones

      @related_zones = children
      @related_zones = parent_zone.children if @related_zones.empty?
      @related_zones = @related_zones.sort_by { |z| - z.cache.cumulative_infections }
      @related_zones
    end
  end
end
