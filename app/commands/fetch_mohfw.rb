# frozen_string_literal: true

require "digest"

class FetchMohfw < BaseCommand
  def self.perform_task
    new.call_with_transaction
  end

  attr_reader :response, :raw_patients, :unknown_districts

  def run
    @unknown_districts = {}
    log(:yellow, "Starting job #{run_id}")
    result = fetch &&
             create_snapshot_if_needed &&
             errors.empty?

    mark_job(result)
    log(:yellow, "Finished job #{run_id}")
    log(:yellow, "Done!", return_value: result)
  rescue StandardError => e
    line = e.backtrace.select { |l| l =~ %r{app/} }.first.sub(Rails.root.to_s, "")
    log(:red, "* Failed with #{e.class} #{e.message} on #{line.strip}")
    add_error("Failed with #{e.class} #{e.message}")
    mark_job(false)
  end

  private

  def fetch
    log(:yellow, "* Calling www.mohfw.gov.in/dashboard/data/data.json")
    @response = ::Excon.get("https://www.mohfw.gov.in/dashboard/data/data.json")
    unless response.status == 200
      log(:red, "    > Got #{response.status}. Aborting...")
      return false
    end
    log(:green, "    > Got #{response.status}. Parsing")
  end

  def create_snapshot_if_needed
    return log(:blue, "* Skipping snapshot creation as nothing as changed") if DataSnapshot.exists? signature: response_signature

    snapshot = DataSnapshot.new(
      source:        source.code,
      api_code:      "mohfw/dashboard",
      signature:     response_signature,
      job_code:      job.code,
      raw_data:      parsed_response,
      downloaded_at: t_start
    )
    snapshot.save!
  end

  def response_signature
    @response_signature ||= Digest::MD5.hexdigest(parsed_response.sort_by { |st| st["state_name"] }.map { |st| st.values.map(&:to_s).map(&:strip).join(";") }.join(";"))
  end

  def parsed_response
    @parsed_response ||= JSON.parse(response.body)
  end

  def log(color, msg, return_value: true)
    job.logs ||= []
    job.logs << { t: t, msg: msg }
    puts_colored color.to_sym, "#{format('%.3f', t).rjust(5)}s - #{msg}"
    return_value
  end

  def source
    @source ||= Source["mohfw"] || Source.new(code: "mohfw", slug: "mohfw-gov", name: "mohfw.gov.in").tap(&:save!)
  end

  def job
    @job ||= Job.new(code: run_id, slug: run_id, logs: [], started_at: t_start, source: source.code)
  end

  def mark_job(result)
    f = result ? :finished_at : :crashed_at
    job[f] = Time.zone.now
    job.update_count = 0 if result
    job.save!
    result
  end

  def run_id
    @run_id ||= "mohfw-#{Time.zone.now.to_f}"
  end
end
