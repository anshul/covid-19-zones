# frozen_string_literal: true

module V2
  class Fact < ApplicationRecord
    serialize :details, ::JsonbSerializer
    validates :entity_slug, :entity_type, :fact_type, :sequence, :details, :happened_at, presence: true
  end
end
