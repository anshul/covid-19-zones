# frozen_string_literal: true

class FetchRawData
  def initialize
    @response = nil
  end

  attr_reader :response

  def call_endpoint
    puts_yellow "Requesting covid19india.org"
    @response = ::Excon.get("https://api.covid19india.org/raw_data.json")
    puts_green "Response recieved"

    parse_response(body: response.body) if response.status == 200
  end

  def parse_response(body:)
    # TODO: make this idempotent
    puts_yellow "Parsing reponse"

    json_data = JSON.parse(body)

    # TODO: Refactor this
    json_data["raw_data"].each do |data|
      puts_yellow "Parsing data for patient number ##{data['patientnumber']}"

      current_patient_count = Patient.count + 1

      patient = Patient.new
      detected_state = data["detectedstate"].parameterize
      state = State.find_by(slug: detected_state)
      state_code = detected_state.presence ? state.blank? ? detected_state : state.code : "unknonw-state"

      detected_district = data["detecteddistrict"].parameterize
      district = District.find_by(slug: detected_district)
      district_code = detected_district.presence ? district.blank? ? detected_district : district.code : "unknonw-district"

      city = data["detectedcity"].parameterize.presence || "unknonw-city"
      patient.slug = "in--#{state_code}--#{district_code}--#{city}--#{current_patient_count}"
      patient.code = "in--#{state_code}--#{district_code}--#{city}--#{current_patient_count}"
      patient.external_code = data["patientnumber"]
      patient.status = data["currentstatus"].parameterize.presence ? data["currentstatus"].parameterize : "unknown"
      patient.zone_code = "in/#{state_code}/#{district_code}/#{city}"
      patient.gender = data["gender"]
      patient.age = data["agebracket"]
      patient.nationality = data["nationality"]
      patient.transmission_type = data["typeoftransmission"]
      patient.announced_on = data["dateannounced"]
      patient.status_changed_on = data["statuschangedate"]

      source = Source.new
      source.slug = "covid2019-india-#{current_patient_count}"
      source.code = "covid2019-india-#{current_patient_count}"
      source.name = "INDIA COVID-19 TRACKER"
      source.details = {
        source_1: data["source1"],
        source_2: data["source2"],
        source_3: data["source3"]
      }.to_json

      patient.source = source.code if source.save

      next if patient.save

      puts_red "Parsing data for patient number ##{data['patientnumber']}, error: #{patient.errors.full_messages.to_sentence}"
    end
  end

  def puts_red(str)
    puts_colored :red, str
  end

  def puts_blue(str)
    puts_colored :blue, str
  end

  def puts_green(str)
    puts_colored :green, str
  end

  def puts_yellow(str)
    puts_colored :yellow, str
  end

  def puts_colored(color, str)
    color_code = {
      red:    31,
      green:  32,
      yellow: 33,
      blue:   34
    }[color.to_sym] || 35
    send(:puts, "\e[#{color_code}m#{str}\e[0m")
  end
end
