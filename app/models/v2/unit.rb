# frozen_string_literal: true

module V2
  class Unit < ApplicationRecord
    validates :code, :name, :population, :population_year, :area_sq_km, presence: true

    has_many :posts, class_name: "V2::Post", dependent: :delete_all, foreign_key: "unit_code", primary_key: "code", inverse_of: :units
    has_many :published_posts, -> { where(published: true) }, class_name: "V2::Post", dependent: :delete_all, foreign_key: "unit_code", primary_key: "code", inverse_of: false
    has_many :draft_posts, -> { where(published: true) }, class_name: "V2::Post", dependent: :delete_all, foreign_key: "unit_code", primary_key: "code", inverse_of: false
    has_many :zones, through: :published_posts

    CATEGORIES = %w[country state district city ward].freeze
    validates :category, inclusion: { in: CATEGORIES }
  end
end
