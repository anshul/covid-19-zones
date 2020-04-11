# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = Rails.root.join("vcr-casettes")
  config.hook_into :excon, :webmock
  config.ignore_hosts(
    "chromedriver.storage.googleapis.com"
  )
  config.ignore_localhost = true
end
