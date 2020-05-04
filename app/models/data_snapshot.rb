# frozen_string_literal: true

class DataSnapshot < ApplicationRecord
  validates :source, :api_code, :signature, :job_code, :raw_data, presence: true

  def mohfw_total
    @mohfw_total ||= %w[cured death positive].index_with { |f| raw_data.map { |state| state[f].to_i }.sum }
  end

  def self.mohfw
    @mohfw ||= where(source: "mohfw").order(:downloaded_at)
  end

  def self.mohfw_ts
    @mohfw_ts ||= %w[cured death positive].index_with { |f| Hash[mohfw.map { |m| [m.downloaded_at.strftime("%d %B, %l:%M %P"), m.mohfw_total[f]] }] }
  end

  def self.mohfw_tot
    Hash[mohfw.map { |m| [m.downloaded_at.strftime("%d %B, %l:%M %P"), %w[cured death positive].map { |f| m.mohfw_total[f] }.sum] }]
  end
end
