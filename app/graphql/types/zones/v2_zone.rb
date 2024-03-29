# frozen_string_literal: true

module Types
  module Zones
    class TsPoint < Types::BaseObject
      field :dt, String, null: false
      field :new_inf, Float, null: false
      field :new_inf_sma5, Float, null: false
      field :tot_inf, Float, null: false
      field :tot_inf_sma5, Float, null: false
    end

    class V2Zone < Types::BaseObject
      field :code, String, null: false
      field :name, String, null: false
      field :unit_codes, [String], null: false
      field :parent, ::Types::Zones::V2Zone, null: true
      field :children, [::Types::Zones::V2Zone], null: true
      field :related, [::Types::Zones::V2Zone], null: false
      field :category, String, null: false
      field :p_category, String, null: false

      field :chart, [::Types::Zones::TsPoint], null: false

      field :current_actives, Int, null: false
      field :cumulative_infections, Int, null: false
      field :cumulative_recoveries, Int, null: false
      field :cumulative_fatalities, Int, null: false
      field :cumulative_tests, Int, null: false

      field :per_million_actives, Float, null: false
      field :per_million_infections, Float, null: false
      field :per_million_recoveries, Float, null: false
      field :per_million_fatalities, Float, null: false
      field :per_million_tests, Float, null: false

      field :f_as_of, String, null: false
      field :f_est_population, String, null: false
      field :f_est_population_year, String, null: false
      field :f_area, String, null: false
      field :attribution_md, String, null: true
    end
  end
end
