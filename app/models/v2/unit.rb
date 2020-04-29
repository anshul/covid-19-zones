# frozen_string_literal: true

module V2
  class Unit < ApplicationRecord
    validates :code, :name, :population, :population_year, :area_sq_km, presence: true

    belongs_to :parent, class_name: "::V2::Unit", foreign_key: "parent_code", primary_key: "code", inverse_of: :children, optional: true
    has_many :children, class_name: "::V2::Unit", foreign_key: "parent_code", primary_key: "code", inverse_of: :parent, dependent: :delete_all
    belongs_to :owner, class_name: "::User", foreign_key: "maintainer", primary_key: "email", inverse_of: :units

    has_many :posts, class_name: "V2::Post", dependent: :delete_all, foreign_key: "unit_code", primary_key: "code", inverse_of: :unit
    has_many :zones, through: :posts
    has_many :streams, class_name: "V2::Stream", foreign_key: :unit_code, primary_key: :code, inverse_of: :unit, dependent: :delete_all
    has_one :override, class_name: "V2::Override", foreign_key: :code, primary_key: :code, inverse_of: :unit, dependent: :delete

    CATEGORIES = %w[country state district city ward].freeze
    validates :category, inclusion: { in: CATEGORIES }
  end
end
