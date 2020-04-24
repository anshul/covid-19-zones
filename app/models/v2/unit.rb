# frozen_string_literal: true

module V2
  class Unit < ApplicationRecord
    validates :code, :name, :population, :population_year, :area_sq_km, presence: true

    CATEGORIES = %w[country state district city ward].freeze
    validates :category, inclusion: { in: CATEGORIES }
  end
end
