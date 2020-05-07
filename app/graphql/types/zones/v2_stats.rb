# frozen_string_literal: true

module Types
  module Zones
    class V2Stats < Types::BaseObject
      field :zones, [::Types::Zones::V2Zone], null: false
    end
  end
end
