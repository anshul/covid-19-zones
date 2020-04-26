# frozen_string_literal: true

module V2
  class Origin < ApplicationRecord
    validates :code, :name, presence: true
    has_many :streams, class_name: "V2::Stream", foreign_key: :origin_code, primary_key: :code, inverse_of: :origin, dependent: :delete_all
    has_many :snapshots, class_name: "V2::Snapshot", foreign_key: :origin_code, primary_key: :code, inverse_of: :origin, dependent: :delete_all
  end
end
