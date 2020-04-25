# frozen_string_literal: true

class ImportWiki < BaseCommand
  def self.perform_task
    new.call!
  end

  attr_reader :response, :raw_patients
  def run
    create_india!
    log " - v1: We have #{Country.count} countries, #{State.count} states, #{District.count} districts, #{City.count} cities, #{Locality.count} localities."
    true
  end

  def create_india!
    country = Country["in"] || Country.new(slug: "india", code: "in", name: "India", search_name: "india")
    log "  * #{country.code} #{country.type.downcase} added" unless country.id
    country.save! unless country.id
    wiki = File.read(Rails.root.join("data/india-districts.wiki"))
    wiki.split(/^===/).reject { |section| section.length < 10 }.map(&:each_line).map(&:to_a).each do |lines|
      create_indian_states!(country: country, lines: lines)
    end
    country = Country.find_by(code: country.code)
    country.pop = country.states.map(&:pop).sum
    country.area = country.states.map(&:area).sum
    country.density = country.area > 1 ? country.pop.to_f / country.area : 0
    country.save!
  end

  def namify(name)
    name.split("|").last.gsub(/[^a-zA-Z]+/, " ").strip
  end

  def numerify(num)
    num.to_s.split("|").last.to_s.gsub(/[^0-9\.]+/, "").strip.to_i
  end

  def create_indian_states!(country:, lines:)
    cn = country.code
    st_name, st = lines.first.strip.scan(/(.*)\(([A-Z]+)\)/).first
    st = st.downcase
    state = State["#{cn}/#{st}"] || State.new(slug: country.slug + "/" + st_name.strip.parameterize, code: "#{cn}/#{st}", name: st_name.strip, parent_zone: country.code, search_name: st_name.strip.parameterize)
    log "    - #{state.code} #{state.type.downcase} added (#{state.slug})" unless state.id
    state.save! unless state.id

    lines.map(&:strip).reject { |l| l.length < 60 }.each do |line|
      next unless line[0] == "|"

      create_indian_districts!(country: country, state: state, line: line)
    end
    state = State.find_by(code: state.code)
    state.pop = state.districts.map(&:pop).sum
    state.area = state.districts.map(&:area).sum
    state.density = state.area > 1 ? state.pop.to_f / state.area : 0
    state.save!
  end

  def create_indian_districts!(country:, state:, line:)
    _, dist, fname, hqname, pop2001, farea, fdensity = line.split("||").map(&:strip)

    cn = country.code
    st = state.code.sub("#{cn}/", "")

    dist = dist =~ /dash/ ? namify(fname).parameterize[0, 20] : dist.downcase
    name = namify(fname)
    hq = namify(hqname)
    pop = numerify(pop2001)
    area = numerify(farea)
    density = area >= 1 ? pop.to_f / area : 0
    details = { name: name, pop2001: numerify(pop2001), area: [numerify(farea), "km²"], density: [numerify(fdensity), "/km²"] }
    district = District["#{cn}/#{st}/#{dist}"] ||
               District.new(slug: state.slug + "/" + name.parameterize, code: "#{cn}/#{st}/#{dist}", name: name, parent_zone: state.code, details: details, search_name: name.parameterize, pop: pop, area: area, density: density)
    log "      - #{district.code} #{district.type.downcase} added (#{district.slug})" unless district.id
    district.save! unless district.id

    code = hq.parameterize
    city = City["#{cn}/#{st}/#{dist}/#{code}"] || City.new(slug: district.slug + "/" + hq.parameterize, code: "#{cn}/#{st}/#{dist}/#{code}", name: hq, parent_zone: district.code, search_name: hq.parameterize)
    log "        - #{city.code} #{city.type.downcase} added (#{city.slug})" unless city.id
    city.save! unless city.id
  end

end
