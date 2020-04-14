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

      patient_already_exists = Patient.exists?(code: Patient.code_for(row["patientnumber"]))

      process_existing_patient(row) if patient_already_exists
      process_new_patient(row) unless patient_already_exists
    end
  end

  def process_existing_patient(row)
    patient = Patient.find_by(code: Patient.code_for(row["patientnumber"]))

    zone_code = zone_code_for(row)
    status_change_date = parse_as_date(row["statuschangedate"])

    if (patient.status_changed_on != status_change_date) || patient.zone_code != zone_code
      patient.assign_attributes(
        status:    row["currentstatus"].parameterize,
        zone_code: zone_code,
        **PATIENT_ATTRS.transform_values { |key| row[key.to_s] }
      )

      puts_red "Error: ##{row['patientnumber']} => #{patient.errors.full_messages.to_sentence}" unless patient.save
    else
      puts_green "Skipping ##{row['patientnumber']}"
    end
  end

  def process_new_patient(row)
    patient_number = row["patientnumber"]
    slug = Patient.slug_for(patient_number)
    code = Patient.code_for(patient_number)

    patient = Patient.new(
      slug:      slug,
      code:      code,
      status:    row["currentstatus"].parameterize,
      zone_code: zone_code_for(row),
      **PATIENT_ATTRS.transform_values { |key| row[key.to_s] }
    )

    source = new_source_for(row)

    patient.source = source.code if source.save
    return if patient.save

    source.destroy
    puts_red "Error: ##{row['patientnumber']} => #{patient.errors.full_messages.to_sentence}"
  end

  def zone_code_for(row)
    zone_code = nil

    state = State.find_by(name: row["detectedstate"])
    zone_code = formatted_code(state.code) if state.present?

    district = District.find_by(name: row["detecteddistrict"])
    zone_code = formatted_code(district.code) if district.present?

    city = City.find_by(name: row["detectedcity"])
    zone_code = formatted_code(city.code) if city.present?

    zone_code.nil? ? formatted_code("in") : zone_code
  end

  def formatted_code(code)
    code_parts = code.split("/")
    unknowns = ["unknown"] * (5 - code_parts.count)
    (code_parts + unknowns).join("/")
  end

  def new_source_for(row)
    patient_number = row["patientnumber"]

    Source.new(
      slug:    Source.slug_for(patient_number),
      code:    Source.code_for(patient_number),
      name:    "INDIA COVID-19 TRACKER",
      details: {
        source_1: row["source1"],
        source_2: row["source2"],
        source_3: row["source3"]
      }
    )
  end

  def parse_as_date(val)
    val.present? ? Date.parse(val) : val
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
