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

  def run
    valid? &&
      show
  end

  def self.master
    @master ||= JSON.parse(File.read(Rails.root.join("topojson/india-districts-727.json")))
  end

  def self.geometries
    @geometries ||= master["objects"]["india-districts-727"]["geometries"]
  end

  private

  def show
    @result[:map] = master.merge("objects" => { "districts" => { "type" => "GeometryCollection", "geometries" => geometries } })
    @result[:max_ipm] = per_million(:cumulative_infections).values.flatten.max
    @result[:max_fpm] = per_million(:cumulative_fatalities).values.flatten.max
  end

  def geometries
    @geometries ||= master_geometries.map { |h| enhance_geometry(h) }
  end

  def enhance_geometry(geometry)
    district_name = geometry.dig("properties", "district")
    unit = units_index[district_name]
    zone_cache = zones_caches_index[unit.code]

    geometry.merge("properties" => {
                     "zone" => zone_cache.code,
                     "ipm"  => per_million(:cumulative_infections)[zone_cache.code],
                     "fpm"  => per_million(:cumulative_fatalities)[zone_cache.code]
                   })
  end

  def master_geometries
    self.class.geometries
  end

  def master
    self.class.master
  end

  def per_million(attr)
    @per_million ||= {}
    @per_million[attr.to_sym] ||= zones_caches_index.transform_values do |cache|
      (cache[attr].to_f * (1_000_000 / [cache.population, 1].max.to_f)).round(2)
    end
  end

  def units_index
    @units_index ||= ::V2::Unit.all.index_by(&:topojson_value)
  end

  def zones_caches_index
    @zones_caches_index ||= ::V2::ZoneCache.all.index_by(&:code)
  end

  def zones
    @zones ||= ::V2::Zone.where(code: codes)
  end
end
