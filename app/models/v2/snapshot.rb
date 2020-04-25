# frozen_string_literal: true

module V2
  class Snapshot < ApplicationRecord
    validates :origin_code, :signature, :data, :downloaded_at, presence: true
    has_many :streams, dependent: :delete_all
  end
end
