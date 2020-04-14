# frozen_string_literal: true

require "digest"

class FetchCovid19india < BaseCommand
  def self.perform_task
    new.call_with_transaction
  end

  attr_reader :response, :raw_patients

  def run
    log(:yellow, "Starting job #{run_id}:  we have #{Patient.where(source: source.code).count} #{source.code} patient(s).")
    result = fetch &&
             parse &&
             errors.empty?
    mark_job(result)
    log(:yellow, "Done!", return_value: result)
  rescue StandardError => e
    line = e.backtrace.select { |l| l =~ %r{app/} }.first.sub(Rails.root.to_s, "")
    log(:red, "* Failed with #{e.class} #{e.message} on #{line.strip}")
    add_error("Failed with #{e.class} #{e.message}")
    mark_job(false)
  end

  private

  def mark_job(result)
    f = result ? :finished_at : :crashed_at
    job[f] = Time.zone.now
    job.save!
    result
  end

  def fetch
    log(:yellow, "* Calling api.covid19india.org/raw_data.json")
    @response = ::Excon.get("https://api.covid19india.org/raw_data.json")
    unless response.status == 200
      log(:red, "    > Got #{response.status}. Aborting...")
      return false
    end
    log(:green, "    > Got #{response.status}. Parsing")
  end

  def parse
    @raw_patients = JSON.parse(response.body)["raw_data"]
    log(:green, "Found #{new_patients.size} new or updated patients")

    Patient.import!(new_patients, on_duplicate_key_update: { conflict_target: %i[code], columns: (Patient.attribute_names - %w[id first_imported_at]).map(&:to_sym) }, batch_size: 500)
  end

  def new_patients
    return @new_patients if @new_patients

    known_patients = Patient.where(external_signature: patients.map(&:external_signature)).pluck(:code)

    @new_patients = patients.reject { |patient| known_patients.include?(patient.code) }
  end

  def patients
    return @patients if @patients

    @patients = raw_patients.map { |h| parse_row(h) }.compact
  end

  def parse_row(row)
    patient_number = as_str(row["patientnumber"])
    return nil unless patient_number && row["dateannounced"].present?

    Patient.new(
      slug:               Patient.slug_for(patient_number),
      code:               Patient.code_for(patient_number),
      source:             source.code,
      external_code:      patient_number.parameterize,
      status:             row["currentstatus"].parameterize.presence || "unknown",
      status_changed_on:  as_date(row["statuschangedate"]),
      zone_code:          zone_code_for(row),
      external_signature: signature(row),
      external_details:   row,
      announced_on:       as_date(row["dateannounced"]),
      name:               as_str(row["statepatientnumber"]),
      gender:             as_str(row["gender"]),
      age:                as_int(row["age"]),
      first_imported_at:  t_start,
      last_imported_at:   t_start
    )
  end

  def zone_code_for(row)
    state = State.named(parent_zone: "in", name: row["detectedstate"])
    return add_error("No state named #{row['detectedstate']} found") unless state

    district = District.named(parent_zone: state.code, name: row["detecteddistrict"]) || District.other(parent_zone: state.code)
    return add_error("No district named #{row['detecteddistrict']} found in #{state.code}") unless district

    city = City.named_or_new(parent_zone: district.code, name: row["detectedcity"])

    "in/#{state.code}/#{district.code}/#{city.code}/other"
  end

  def signature(row)
    "#{as_str(row['patientnumber'])}-#{Digest::MD5.hexdigest(row.values.map(&:to_s).map(&:strip).sort.join(';'))}"
  end

  def source
    @source ||= Source["covid19india"] || Source.new(code: "covid19india", slug: "covid19india-org", name: "covid19india.org").tap(&:save!)
  end

  def log(color, msg, return_value: true)
    job.logs ||= []
    job.logs << { t: t, msg: msg }
    puts_colored color.to_sym, "#{format('%.3f', t).rjust(5)}s - #{msg}"
    return_value
  end

  def job
    @job ||= Job.new(code: run_id, slug: run_id, logs: [], started_at: t_start, source: source.code)
  end

  def run_id
    @run_id ||= "covid19india-#{Time.zone.now.to_f}"
  end

  def t_start
    @t_start ||= Time.zone.now
  end

  def t
    (Time.zone.now.to_f - t_start.to_f).round(3)
  end

  def as_date(val)
    val.present? ? Date.parse(val) : nil
  end

  def as_str(val)
    val.present? ? val.strip.parameterize : nil
  end

  def as_int(val)
    val.present? ? val.strip.sub(/[^0-9\.]/, "").to_i : nil
  end
end
