# frozen_string_literal: true

module V2
  class Zone < ApplicationRecord
    validates :code, :name, presence: true

    CATEGORIES = %w[country state district city ward].freeze
    validates :category, inclusion: { in: CATEGORIES }

    belongs_to :parent, class_name: "::V2::Zone", foreign_key: "parent_code", primary_key: "code", inverse_of: :children
    has_many :children, class_name: "::V2::Zone", foreign_key: "parent_code", primary_key: "code", inverse_of: :parent, dependent: :delete_all
    belongs_to :maintainer, class_name: "::User", foreign_key: "maintainer", primary_key: "email", inverse_of: :zones
    has_many :posts, class_name: "V2::Post", dependent: :delete_all, foreign_key: "zone_code", primary_key: "code", inverse_of: :zone
    has_many :units, through: :posts
  end
end
