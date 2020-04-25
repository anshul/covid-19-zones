# frozen_string_literal: true

class ImportV2 < BaseCommand
  def self.perform_task
    new.call!
  end

  attr_reader :response, :raw_patients
  def run
    log " - We have #{::V2::Unit.count} units, #{::V2::Zone.count} zones and #{::V2::Post.count} posts."
  end
end
