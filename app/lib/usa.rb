# frozen_string_literal: true

class Usa
  attr_reader :wiki, :cio, :census2010, :raw2019
  def initialize
    @raw2019 = JSON.parse(File.read(Rails.root.join("topojson/usa/counties-albers-10m.json")))
    @census2010 = CSV.parse(File.read(Rails.root.join("data/usa/co-est2019-alldata.csv")).scrub, headers: true).map(&:to_h).map(&:symbolize_keys)
  end

  def countries
    @countries ||= Hash[states.values.group_by { |h| h[:country_code] }.transform_values { |arr| combine(arr).except(:fips_state_code, :state_code, :state).merge(code: "us", country: "USA") }]
  end

  def states
    @states ||= Hash[counties.values.group_by { |h| h[:state_code] }.transform_values { |arr| combine(arr).except(:county, :fips_county_code).merge(code: "us/#{arr.first[:state_code]}") }]
  end

  def combine(arr)
    arr.reduce({}) do |acc, h|
      out = {}
      h.each_key { |k| out[k] = h[k].is_a?(Numeric) ? acc[k].to_f + h[k] : h[k] }
      out
    end
  end

  def counties
    return @counties if @counties

    @counties = {}
    geometries.each do |county|
      county_name = county["properties"]["name"]
      fips_county_code = county["id"]
      fips_state_code = fips_county_code.slice(..1)

      state_name = census_states_lookup[fips_state_code].strip
      state_code = state_name.parameterize

      county_census = census_county_code_lookup[fips_county_code]
      @counties[fips_county_code.to_i] = {
        fips_county_code: fips_county_code,
        fips_state_code:  fips_state_code,
        state_code:       state_code,
        county:           county_name,
        state:            state_name,
        code:             "us/#{state_code}/#{county_name.parameterize}",
        country_code:     "us",
        source:           "census-2019",
        population:       county_census[:POPESTIMATE2019].to_i,
        population_year:  "2019",
        area_sq_km:       0
      }
    end

    @counties
  end

  def geometries
    @geometries ||= raw2019["objects"]["counties"]["geometries"]
  end

  def census_states_lookup
    @census_states_lookup ||= Hash[census2010.map { |d| [d[:STATE], d[:STNAME]] }.uniq(&:first)]
  end

  def census_county_code_lookup
    @census_county_code_lookup ||= census2010.index_by { |z| "#{z[:STATE]}#{z[:COUNTY]}" }
  end
end
