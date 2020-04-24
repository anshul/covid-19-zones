# frozen_string_literal: true

module V2
  class Stream < ApplicationRecord
    validates :code, :type, :unit_code, :origin_code, presence: true
    validates :time_series, :dated, :snapshot_id, presence: true
  end
end
