# frozen_string_literal: true

class India
  attr_reader :wiki, :cio, :census2011, :raw2019
  def initialize
    @raw2019 = JSON.parse(File.read(Rails.root.join("topojson/india-districts-727.json")))
    @wiki = File.read(Rails.root.join("data/india-districts.wiki"))
    @cio =  JSON.parse(File.read(Rails.root.join("data/state_district_wise.json")))
    @census2011 = CSV.read(Rails.root.join("data/pca-full.csv"), headers: true).map(&:to_h).map(&:symbolize_keys)
  end

  def census_districts
    return @census_districts if @census_districts

    @census_districts = {}
    census2011.each do |dist|
      dist = dist.symbolize_keys.merge(
        state: dist["State Name"].sub("&", " and ")
      )
      dist[:st_code] = wiki_states_lookup[]
    end

    @census_districts
  end

  def countries
    @countries ||= Hash[states.values.group_by { |h| h[:country_code] }.transform_values { |arr| combine(arr).except(:st_2011, :state).merge(code: "in", country: "India") }]
  end

  def states
    @states ||= Hash[districts.values.group_by { |h| h[:state_code] }.transform_values { |arr| combine(arr).except(:dist_2011, :district).merge(code: "in/#{arr.first[:state_code]}") }]
  end

  def combine(arr)
    arr.reduce({}) do |acc, h|
      out = {}
      h.each_key { |k| out[k] = h[k].is_a?(Numeric) ? acc[k].to_f + h[k] : h[k] }
      out
    end
  end

  def districts
    return @districts if @districts

    @districts = {}
    geometries.each do |dist|
      h = dist["properties"].symbolize_keys
      state_code = wiki_states_lookup[h[:st_nm].parameterize]
      @districts[h[:dt_code].to_i] = {
        dist_2011:       h[:dt_code].to_i,
        st_2011:         h[:st_code].to_i,
        district:        h[:district],
        state:           h[:st_nm].strip,
        code:            "in/#{state_code}/#{h[:district].parameterize}",
        country_code:    "in",
        state_code:      state_code,
        source:          h[:year],
        population:      0,
        population_year: 0,
        area_sq_km:      0
      }
    end
    census2011.each do |c|
      next unless c[:TRU] == "Total"

      h = @districts[c[:District].to_i]
      h[:population] = c[:TOT_P].to_i
      h[:population_year] = "2011"
      h[:area_sq_km] = c[:TRU1].to_f
    end

    @districts
  end

  def geometries
    @geometries ||= raw2019["objects"]["india-districts-727"]["geometries"]
  end

  def cio_districts
    return @cio_districts if @cio_districts

    @cio_districts = {}
    cio.each do |state|
      state["districtData"].each do |dist|
        dist = dist.symbolize_keys.merge(
          st:    state["statecode"].downcase,
          state: state["state"].strip
        )
        code = "in/#{dist[:st]}/#{dist[:district].parameterize[0, 20]}"
        @cio_districts[code] = dist
      end
    end
    @cio_districts
  end

  def wiki_states_lookup
    @wiki_states_lookup ||= Hash[wiki_states.map { |k, v| [v.parameterize, k] }]
  end

  def wiki_states
    @wiki_states ||= Hash[wiki_districts.values.map { |d| [d[:st], d[:state]] }.uniq(&:first)]
  end

  def cio_states
    @cio_states ||= Hash[cio_districts.values.map { |d| [d[:st], d[:state]] }.uniq(&:first)]
  end

  def wiki_districts
    return @wiki_districts if @wiki_districts

    @wiki_districts = {}
    wiki.split(/^===/).reject { |section| section.length < 10 }.map(&:each_line).map(&:to_a).each do |lines|
      st_name, st = lines.first.strip.scan(/(.*)\(([A-Z]+)\)/).first
      st = st.downcase
      st_name = st_name.strip
      lines.map(&:strip).reject { |l| l.length < 60 }.each do |line|
        next unless line[0] == "|"

        district = extract_wiki_district(line, st, st_name)
        @wiki_districts[district[:code]] = district
      end
    end
    @wiki_districts
  end

  def extract_wiki_district(line, st_code, state_name)
    _, dist, fname, hqname, pop2001, farea, _fdensity = line.split("||").map(&:strip)
    dist = dist =~ /dash/ ? namify(fname).parameterize[0, 20] : dist.downcase
    name = namify(fname)
    hq = namify(hqname)
    {
      code:         "in/#{st_code}/#{dist}",
      district:     name,
      pop2001:      numerify(pop2001),
      area:         numerify(farea),
      st:           st_code,
      parent:       "in/#{st_code}",
      state:        state_name,
      hq:           hq.parameterize,
      headqaurters: hq
    }
  end

  def namify(name)
    name.split("|").last.gsub(/[^a-zA-Z]+/, " ").strip.sub(/ ref name .*/, "")
  end

  def numerify(num)
    num.to_s.split("|").last.to_s.gsub(/[^0-9\.]+/, "").strip.to_i
  end
end
