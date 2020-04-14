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

  PATIENT_ATTRS = {
    external_code:     "patientnumber",
    gender:            "gender",
    age:               "agebracket",
    nationality:       "nationality",
    transmission_type: "typeoftransmission",
    announced_on:      "dateannounced",
    status_changed_on: "statuschangedate"
  }.freeze
  def parse_response(body:)
    # TODO: make this idempotent
    puts_yellow "Parsing reponse"

    json_data = JSON.parse(body)

    # TODO: Refactor this
    json_data["raw_data"].each do |row|
      puts_yellow "Parsing row for patient number ##{row['patientnumber']}"

      patient_number = row["patientnumber"]
      slug = "covid19-india-#{patient_number}"
      code = "c19-in-#{patient_number}"

      state = State.find_by(name: row["detectedstate"])
      state_code = state.present? ? state.code : "unknown-state"

      district = District.find_by(name: row["detecteddistrict"])
      district_code = district.present? ? district.code : "unknown-district"

      city = City.find_by(name: row["detectedcity"])
      city_code = city.present? ? city.code : "unknonw-city"

      patient = Patient.new(
        slug:      slug,
        code:      code,
        status:    row["currentstatus"].parameterize,
        zone_code: "in/#{state_code}/#{district_code}/#{city_code}",
        **PATIENT_ATTRS.transform_values { |key| row[key.to_s] }
      )

      source = Source.new(
        slug:    "covid19-india-#{patient_number}",
        code:    "c19-in-#{patient_number}",
        name:    "INDIA COVID-19 TRACKER",
        details: {
          source_1: row["source1"],
          source_2: row["source2"],
          source_3: row["source3"]
        }
      )

      patient.source = source.code if source.save

      next if patient.save

      puts_red "Error: ##{row['patientnumber']} => #{patient.errors.full_messages.to_sentence}"
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
