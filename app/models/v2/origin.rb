# frozen_string_literal: true

module V2
  class Origin < ApplicationRecord
    validates :code, :name, presence: true
  end
end
