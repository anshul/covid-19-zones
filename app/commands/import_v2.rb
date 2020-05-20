# frozen_string_literal: true

class ImportV2 < BaseCommand
  def self.perform_task
    new.call_with_transaction
  end

  COMBO_ZONES = {
    "in/mh/greater-mumbai": {
      name:              "Mumbai",
      category:          "district",
      maintainer:        "bot@covid19zones.com",
      unit_code_changes: %w[in/mh/mumbai in/mh/mumbai-suburban].index_with { |_d| true }
    }
  }.freeze

  def run
    upsert_india &&
      log(" - v2: We have #{::V2::Unit.count} units, #{::V2::Zone.count} zones and #{::V2::Post.count} posts.") ||
      puts_red("Failed: #{error_message}")
  end

  def upsert_india
    india = ::India.new
    upsert(arr: india.countries.values, category: "country", topojson_file: "india.json", topojson_key: nil) &&
      upsert(arr: india.states.values, category: "state", topojson_file: "india.json", topojson_key: "st_nm") &&
      upsert(arr: india.districts.values, category: "district", topojson_file: "india.json", topojson_key: "district") &&
      upsert_combo_zones &&
      unpublish_subcombo_zones
  end

  def upsert_combo_zones
    COMBO_ZONES.all? do |code, zone_attrs|
      details = zone_attrs.merge(parent_code: code.to_s.split("/")[0..-2].join("/"), published_at: Time.zone.now)
      cmd = ::V2::RecordFact.new(details: details, entity_type: "unit", entity_slug: code.to_s, fact_type: "zone_patched")
      cmd.call || add_error(cmd.error_message)
    end
  end

  def unpublish_subcombo_zones
    units = COMBO_ZONES.values.map { |zone_attrs| zone_attrs[:unit_code_changes].keys }.flatten.sort.uniq
    units.all? do |code|
      cmd = ::V2::RecordFact.new(details: { unpublished_by: "bot@covid19zones.com" }, entity_type: "unit", entity_slug: code, fact_type: :zone_unpublished)
      cmd.call || add_error(cmd.error_message)
    end
  end

  def upsert(arr:, **common_attrs)
    arr.all? do |attr|
      cmd = ::V2::RecordFact.new(details: unit_params(attr.merge(common_attrs), common_attrs[:category]).merge(common_attrs), entity_type: "unit", entity_slug: attr[:code], fact_type: "unit_patched")
      cmd.call || add_error(cmd.error_message)
    end
  end

  def unit_params(attr, key)
    out = attr.slice(:code, :name, :population, :population_year, :area_sq_km, :topojson_file, :topojson_key)
    out[:name] ||= attr[key.to_sym]
    out[:parent_code] ||= out[:code].split("/")[0..-2].join("/")
    out[:parent_code] = nil if out[:parent_code].blank?
    out[:details] ||= {}
    out[:maintainer] ||= "bot@covid19zones.com"
    out[:topojson_value] ||= nil
    out[:topojson_value] ||= out[:name] if out[:topojson_file] && out[:topojson_key]
    out
  end
end
