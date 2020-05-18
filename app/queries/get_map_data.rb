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

  def self.geometries
    @geometries ||= master["objects"]["india-districts-2019-734"]["geometries"]
  end

  private

  def show
    @result[:map] = master.merge("objects" => { "districts" => { "type" => "GeometryCollection", "geometries" => geometries } })
    @result[:max_ipm] = geometries.map { |geom| geom.dig("properties", "ipm") }.compact.max
    @result[:max_fpm] = geometries.map { |geom| geom.dig("properties", "fpm") }.compact.max
  end

  def geometries
    @geometries ||= master_geometries.map { |h| enhance_geometry(h) }
  end

  def enhance_geometry(geometry)
    district_name = geometry.dig("properties", "district")
    unit = units_index[district_name]
    return geometry.merge(default_properties(geometry)) if unit.blank?

    zone_cache = zones_caches_index[unit.code]
    return geometry.merge(default_properties(geometry, zone_code: unit.code)) if zone_cache.blank?

    geometry.merge("properties" => {
                     **geometry["properties"],
                     "zone" => zone_cache.code,
                     "ipm"  => per_million(:infections)[zone_cache.code],
                     "fpm"  => per_million(:fatalities)[zone_cache.code]
                   })
  end

  def default_properties(geometry, zone_code: nil)
    {
      "properties" => {
        **geometry["properties"],
        "zone" => zone_code || "",
        "ipm"  => 0,
        "fpm"  => 0
      }
    }
  end

  def master_geometries
    self.class.geometries
  end

  def master
    self.class.master
  end

  def per_million(attr)
    @per_million ||= {}
    @per_million[attr.to_sym] ||= zones_caches_index.transform_values { |cache| cache.send("per_million_#{attr}") }
  end

  def units_index
    @units_index ||= ::V2::Unit.where(topojson_file: MAP_FILE).index_by(&:topojson_value)
  end

  def zones_caches_index
    @zones_caches_index ||= ::V2::ZoneCache.all.index_by(&:code)
  end

  def zones
    @zones ||= ::V2::Zone.where(code: codes)
  end
end
