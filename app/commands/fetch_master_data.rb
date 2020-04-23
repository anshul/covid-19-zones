# frozen_string_literal: true

require "google_drive"

class FetchMasterData < BaseCommand
  def self.perform_task
    new.call_with_transaction
  end

  attr_reader :response, :raw_patients, :unknown_districts

  def run
    log(:yellow, "Starting job #{run_id}:  we have #{Patient.where(source: source.code).count} #{source.code} patient(s).")
    result = parse &&
             persist &&
             errors.empty?
    mark_job(result)
    log(:yellow, "Finished job #{run_id}:  we have #{Patient.where(source: source.code).count} #{source.code} patient(s).")
    log(:yellow, "Done!", return_value: result)
  rescue StandardError => e
    line = e..select { |l| l =~ %r{app/} }.first.sub(Rails.root.to_s, "")
    log(:red, "* Failed with #{e.class} #{e.message} on #{line.strip}")
    add_error("Failed with #{e.class} #{e.message}")
    mark_job(false)
  end

  def parse
    parse_metadata &&
      parse_regions &&
      parse_incident_regions &&
      # parse_notes &&
      parse_data
  end

  def persist
    persist_region &&
      persist_data
  end

  def parse_metadata
    @parsed_metadata = (1..metadata.num_rows).map do |row|
      { [metadata[row, 1]] => metadata[row, 2] }
    end

    true
  end

  def parse_regions
    @parsed_regions = parse_spreadsheet(regions)

    true
  end

  def parse_incident_regions
    @parsed_incident_regions = parse_spreadsheet(incident_regions)

    true
  end

  def parse_notes
    @parsed_notes = parse_spreadsheet(notes)

    true
  end

  def parse_data
    @parsed_data = parse_spreadsheet(data)

    true
  end

  def parse_spreadsheet(sheet)
    parsed_sheet = []
    (2..sheet.num_rows).each do |row|
      parsed_row = {}
      (1..sheet.num_cols).each do |col|
        parsed_row[sheet[1, col].to_sym] = sheet[row, col]
      end
      parsed_sheet.push(parsed_row)
    end

    parsed_sheet
  end

  def persist_region
    zones = @parsed_regions.map do |region|
      parent_code = nil
      parent_code = region[:parent_id] if region[:parent_id] != "_na"
      code = "#{region[:parent_id]}/#{region[:id]}"
      code = region[:id] if region[:parent_id] == "_na"
      Zone.new(
        type:        region[:region_type].titleize,
        slug:        region[:region_name].parameterize,
        code:        code,
        name:        region[:region_name],
        search_name: region[:tags_csv],
        parent_zone: parent_code,
        zone_md:     region[:data_comment],
        pop:         region[:population].to_f,
        details:     {
          data_source: region[:data_source]
        }
      )
    end

    Zone.import(zones, batch_size: 50)
  end

  def persist_data; end

  def sheet
    @sheet ||= session.spreadsheet_by_key("19l7vn8uCtTMpDLHepJqp5WC1VwSYxoo8joJOzQso7Gk")
  end

  def metadata
    @metadata ||= sheet.worksheets[0]
  end

  def regions
    @regions ||= sheet.worksheets[1]
  end

  def incident_regions
    @incident_regions ||= sheet.worksheets[2]
  end

  def notes
    @notes ||= sheet.worksheets[3]
  end

  def data
    @data ||= sheet.worksheets[4]
  end

  def session
    @session ||= GoogleDrive::Session.from_config("config.json")
  end

  def mark_job(result)
    f = result ? :finished_at : :crashed_at
    job[f] = Time.zone.now
    job.update_count = new_patients.size if result
    job.save!
    result
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
    @run_id ||= "master-sheet--#{Time.zone.now.to_f}"
  end

  def source
    @source ||= Source.new(code: "master", slug: "master", name: "Master Sheet").tap(&:save!)
  end
end
