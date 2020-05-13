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
  end

  def geometries
    @geometries ||= master_geometries.map { |h| h.merge("properties" => { "zone" => h["district"], "v0" => 100 }) }
  end

  def master_geometries
    self.class.geometries
  end

  def master
    self.class.master
  end

  def zones
    @zones ||= ::V2::Zone.where(code: codes)
  end
end
