# frozen_string_literal: true

module Types
  module Zones
    class CaseCount < Types::BaseObject
      field :zone_name, String, null: false
      field :count, Int, null: false
    end

    class CompareStats < Types::BaseObject
      field :zones, [::Types::Zones::Zone], null: false
      field :total_cases, [Types::Zones::CaseCount], null: false
      field :cumulative_confirmed_cases, ::Types::LineChartType, null: false
      field :new_cases, ::Types::LineChartType, null: false
    end
  end
end
