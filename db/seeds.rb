# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Seeding zone data"

country = Country.new
country.slug = "india"
country.code = "in"
country.name = "India"
country.save

puts "1 country imported"

file = File.open("data/districts.json", "r")
json_data = JSON.parse(file.read)

state_data = json_data.map { |data| { state_code: data["properties"]["ID_1"], state_name: data["properties"]["NAME_1"] } }.uniq
state_data.each do |data|
  state = State.new
  state.slug = "india/#{data[:state_name].parameterize}"
  state.code = "in/#{data[:state_code].parameterize}"
  state.name = data[:state_name]
  state.parent_zone = "in"
  state.save
end

puts "#{state_data.count} states imported"

district_data = json_data.map { |data| { district_name: data["properties"]["NAME_2"], state_code: data["properties"]["ID_1"], district_code: data["properties"]["HASC_2"] } }.uniq
district_data.each do |data|
  district = District.new
  district.slug = "india/#{data[:state_code].parameterize}/#{data[:district_name].parameterize}"
  district.code = data[:district_code].split(".").join("/").downcase
  district.name = data[:district_name]
  district.parent_zone = "in/#{data[:state_code].downcase}"
  district.save
end

puts "#{district_data.count} districts imported"
