# frozen_string_literal: true

module V2
  class Snapshot < ApplicationRecord
    validates :code, :unit_code, :origin_code, :type, :signature, :data, :downloaded_at, presence: true
  end
end
