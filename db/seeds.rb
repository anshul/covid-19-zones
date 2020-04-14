# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def say(*msg)
  send(:puts, *msg)
end

namify = ->(name) { name.split("|").last.gsub(/[^a-zA-Z]+/, " ").strip }
numerify = ->(num) { num.to_s.split("|").last.to_s.gsub(/[^0-9\.]+/, "").strip.to_i }

country = Country["in"] || Country.new(slug: "india", code: "in", name: "India")
say "  * #{country.code} #{country.type.downcase} added" unless country.id
country.save! unless country.id
cn = country.code

wiki = File.read(Rails.root.join("data/india-districts.wiki"))
wiki.split(/^===/).reject { |section| section.length < 10 }.map(&:each_line).map(&:to_a).each do |lines|
  st_name, st = lines.first.strip.scan(/(.*)\(([A-Z]+)\)/).first
  st = st.downcase
  state = State["#{cn}/#{st}"] || State.new(slug: country.slug + "/" + st_name.parameterize, code: "#{cn}/#{st}", name: st_name, parent_zone: country.code)
  say "    - #{state.code} #{state.type.downcase} added (#{state.slug})" unless state.id
  state.save! unless state.id

  lines.map(&:strip).reject { |l| l.length < 60 }.each do |l|
    next unless l[0] == "|"

    _, dist, fname, hqname, pop2001, farea, fdensity = l.split("||").map(&:strip)

    dist = dist =~ /dash/ ? namify.call(fname).parameterize[0, 8] : dist.downcase
    name = namify.call(fname)
    hq = namify.call(hqname)
    details = { name: name, pop2001: numerify.call(pop2001), area: [numerify.call(farea), ""], density: [numerify.call(fdensity), ""] }
    district = District["#{cn}/#{st}/#{dist}"] || District.new(slug: state.slug + "/" + name.parameterize, code: "#{cn}/#{st}/#{dist}", name: name, parent_zone: state.code, details: details)
    say "      - #{district.code} #{district.type.downcase} added (#{district.slug})" unless district.id
    district.save! unless district.id

    code = hq.parameterize
    city = City["#{cn}/#{st}/#{dist}/#{code}"] || City.new(slug: district.slug + "/" + hq.parameterize, code: "#{cn}/#{st}/#{dist}/#{code}", name: hq, parent_zone: district.code)
    say "        - #{city.code} #{city.type.downcase} added (#{city.slug})" unless city.id
    city.save! unless city.id
  end
end

say " - We have #{Country.count} countries, #{State.count} states, #{District.count} districts, #{City.count} cities, #{Locality.count} localities."
