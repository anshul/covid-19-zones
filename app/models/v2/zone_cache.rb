# frozen_string_literal: true

module V2
  class ZoneCache < ApplicationRecord
    belongs_to :zone, class_name: "::V2::Zone", foreign_key: :code, primary_key: :code, inverse_of: :cache
  end
end
