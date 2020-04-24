# frozen_string_literal: true

module V2
  class Zone < ApplicationRecord
    validates :code, :name, presence: true

    CATEGORIES = %w[country state district city ward].freeze
    validates :category, inclusion: { in: CATEGORIES }
  end
end
