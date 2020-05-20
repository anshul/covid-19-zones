# frozen_string_literal: true

class GetMapData < BaseQuery
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

  def district_geometries
    @district_geometries ||= self.class.district_geometries.map { |h| enhance_geometry(h, "district") }
  end

  def state_geometries
    @state_geometries ||= self.class.state_geometries.map { |h| enhance_geometry(h, "st_nm") }
  end

  def enhance_geometry(geometry, region)
    region_name = geometry.dig("properties", region)
    unit = units_index[region_name]
    return geometry.merge(default_properties(geometry)) if unit.blank?

    zone_cache = zones_caches_index[unit.code]
    return geometry.merge(default_properties(geometry, zone_code: unit.code)) if zone_cache.blank?

    properties = geometry["properties"]
    geometry.merge(
      "properties" => {
        "d"   => properties["district"],
        "s"   => properties["st_nm"],
        "z"   => zone_cache.code,
        "u"   => unit.code,
        "ipm" => zone_cache.per_million_infections,
        "fpm" => zone_cache.per_million_fatalities
      }
    )
  end

  def default_properties(geometry, zone_code: nil)
    properties = geometry["properties"]
    {
      "properties" => {
        "d"   => properties["district"],
        "s"   => properties["st_nm"],
        "z"   => zone_code || "",
        "u"   => zone_code || "",
        "ipm" => -1,
        "fpm" => -1
      }
    }
  end

  def master
    self.class.master
  end

  def units_index
    @units_index ||= ::V2::Unit.where(topojson_file: MAP_FILE).index_by(&:topojson_value)
  end

  def zones_caches_index
    @zones_caches_index ||= ::V2::ZoneCache.joins(:zone).where.not("v2_zones.published_at" => nil).flat_map { |z| z.unit_codes.map { |code| [code, z] } }.to_h
  end
end
