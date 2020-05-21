# frozen_string_literal: true

class GetMapData < BaseQuery
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  attr_reader :codes, :log
  def initialize(codes:, log: nil)
    @codes = codes
    @result = {}
    @log = log || lambda { |color, msg, return_value:|
      puts_colored color.to_sym, "#{format('%.3f', t).rjust(5)}s - #{msg}"
      return_value
    }
  end

  MAP_FILE = "india.json"
  def run
    valid? &&
      show
  end

  def self.master
    @master ||= JSON.parse(File.read(Rails.root.join("topojson/#{MAP_FILE}")))
  end

  def self.district_geometries
    @district_geometries ||= master["objects"]["india-districts-2019-734"]["geometries"]
  end

  def self.state_geometries
    @state_geometries ||= master["objects"]["india-states"]["geometries"]
  end

  private

  def show
    @result[:map] = master.merge("objects" => {
                                   "districts" => { "type" => "GeometryCollection", "geometries" => district_geometries },
                                   "states"    => { "type" => "GeometryCollection", "geometries" => state_geometries }
                                 })
    @result[:max_ipm] = district_geometries.map { |geom| geom.dig("properties", "ipm") }.compact.max
    @result[:max_fpm] = district_geometries.map { |geom| geom.dig("properties", "fpm") }.compact.max
  end

  def cache_key
    @cache_key ||= "v1/#{::V2::ZoneCache.maximum(:cached_at)}"
  end

  def district_geometries
    @district_geometries ||= Rails.cache.fetch("district_geometries/#{cache_key}", expires_in: 1.hour) do
      self.class.district_geometries.map { |h| enhance_geometry(h, "district", "st_nm") }
    end
  end

  def state_geometries
    @state_geometries ||= Rails.cache.fetch("state_geometries/#{cache_key}", expires_in: 1.hour) do
      self.class.state_geometries.map { |h| enhance_geometry(h, "st_nm", nil) }
    end
  end

  def enhance_geometry(geometry, region_key, parent_region_key)
    region_name = geometry.dig("properties", region_key)
    parent_region_name = parent_region_key.present? ? geometry.dig("properties", parent_region_key) : nil

    unit = units_topo_index.dig(parent_region_name, region_name)
    return geometry.merge(default_properties(geometry, zone_code: "in/unknown/")) if unit.blank?

    zone_cache = zones_caches_index[unit.code]
    return geometry.merge(default_properties(geometry, zone_code: unit.code + "/")) if zone_cache.blank?

    geometry.merge(
      "properties" => {
        "name" => zone_cache.name,
        "pz"   => zone_cache.parent_code + "/",
        "z"    => zone_cache.code + "/",
        "u"    => unit.code + "/",
        "ipm"  => zone_cache.per_million_infections,
        "fpm"  => zone_cache.per_million_fatalities,
        "i"    => zone_cache.cumulative_infections,
        "f"    => zone_cache.cumulative_fatalities,
        "pop"  => number_with_delimiter(zone_cache.population),
        "yr"   => zone_cache.population_year
      }
    )
  end

  def default_properties(geometry, zone_code: nil)
    properties = geometry["properties"]
    {
      "properties" => {
        "name" => properties["district"],
        "pz"   => zone_code.to_s.split("/")[0..-2].join("/"),
        "z"    => zone_code || "",
        "u"    => zone_code || "",
        "ipm"  => -1,
        "fpm"  => -1,
        "f"    => -1,
        "i"    => -1,
        "pop"  => nil,
        "yr"   => nil
      }
    }
  end

  def master
    self.class.master
  end

  def units_topo_index
    @units_topo_index ||= ::V2::Unit.where(topojson_file: MAP_FILE)
                                    .group_by { |unit| units_code_index[unit.parent_code]&.topojson_value }
                                    .transform_values { |units| units.index_by { |unit| units_code_index[unit.code].topojson_value } }
  end

  def units_code_index
    @units_code_index ||= ::V2::Unit.where(topojson_file: MAP_FILE).index_by(&:code)
  end

  def zones_caches_index
    @zones_caches_index ||= ::V2::ZoneCache.joins(:zone).includes(:zone).where.not("v2_zones.published_at" => nil).flat_map { |z| z.unit_codes.map { |code| [code, z] } }.to_h
  end
end
