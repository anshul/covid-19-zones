# frozen_string_literal: true

module V2
  class Snapshot < ApplicationRecord
    validates :origin_code, :signature, :data, :downloaded_at, presence: true
    has_many :streams, dependent: :delete_all
    belongs_to :origin, class_name: "V2::Origin", foreign_key: :origin_code, primary_key: :code, inverse_of: :snapshots
  end
end
