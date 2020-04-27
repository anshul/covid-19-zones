# frozen_string_literal: true

class ImportOrigins < BaseCommand
  def self.perform_task
    new.call_with_transaction
  end

  attr_reader :response, :raw_patients
  def run
    create_origins &&
      log(" - We have #{::V2::Origin.count} origins") ||
      puts_red("Failed: #{error_message}")
  end

  def create_origins
    origins.all? do |attrs|
      create_origin(attrs)
    end
  end

  def create_origin(attrs)
    origin = ::V2::Origin[attrs[:code]]
    return true if origin && attrs.keys.reject { |k| k =~ /(attribution_text|name)/ }.all? { |k| origin[k] == attrs[k] } && origin[:attribution_text].present? && origin[:name].present?

    origin = ::V2::Origin.find_by(code: attrs[:code]) || ::V2::Origin.new(code: attrs[:code])
    origin.assign_attributes(**attrs)
    log "   > #{origin.id ? 'Updating' : 'Creating'} origin #{attrs[:code]}"
    origin.save || add_error(origin.error_message)
  end

  def origins
    [
      {
        code:             "covid19-india-raw-data",
        name:             "cio-db1",
        data_category:    "json",
        attribution_text: "covid19india.org",
        source_name:      "www.covid19india.org",
        source_subname:   "api.covid19india.org/raw_data.json",
        source_url:       "https://api.covid19india.org/raw_data.json"
      },
      {
        code:             "covid19-india-deaths-and-recoveries",
        name:             "cio-db2",
        data_category:    "json",
        attribution_text: "covid19india.org",
        source_name:      "www.covid19india.org",
        source_subname:   "api.covid19india.org/deaths_recoveries.json",
        source_url:       "https://api.covid19india.org/deaths_recoveries.json"
      },
      {
        code:             "covid19-india-state-districts",
        name:             "cio-git-v2",
        data_category:    "github_history",
        attribution_text: "daily snapshots from covid19india.org",
        source_name:      "www.covid19india.org",
        source_subname:   "api.covid19india.org/v2/state_district_wise.json",
        source_url:       "covid19india/api",
        details:          {
          branches: %w[master gh-pages],
          path:     "v2/state_district_wise.json"
        }
      }
    ]
  end
end
