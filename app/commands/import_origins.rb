# frozen_string_literal: true

class ImportOrigins < BaseCommand
  def self.perform_task
    new.call_with_transaction
  end

  attr_reader :response, :raw_patients
  def run
    create_origins &&
      log(" - We have #{V2::Origin.count} origins") ||
      puts_red("Failed: #{error_message}")
  end

  def create_origins
    origins.all? do |attrs|
      create_origin(attrs)
    end
  end

  def create_origin(attrs)
    return true if V2::Origin.exists?(code: attrs[:code])

    origin = V2::Origin.new(**attrs)
    log "   > Creating origin #{attrs[:code]}"
    origin.save || add_error(origin.error_message)
  end

  def origins
    [
      {
        code:             "covid19-india-raw-data",
        name:             "Covid19 India",
        data_category:    "json",
        attribution_text: "",
        source_name:      "www.covid19india.org",
        source_subname:   "api.covid19india.org/raw_data.json",
        source_url:       "https://api.covid19india.org/raw_data.json"
      }
    ]
  end
end
