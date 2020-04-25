# frozen_string_literal: true

module V2
  class Zone < ApplicationRecord
    validates :code, :name, presence: true

    CATEGORIES = %w[country state district city ward].freeze
    validates :category, inclusion: { in: CATEGORIES }

    has_many :posts, class_name: "V2::Post", dependent: :delete_all, foreign_key: "zone_code", primary_key: "code", inverse_of: :zone
    has_many :units, through: :posts
  end
end
