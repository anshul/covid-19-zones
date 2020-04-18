# frozen_string_literal: true

module Types
  class LineChartType < Types::BaseObject
    field :x_axis_key, String, null: false
    field :line_keys, [String], null: false
    field :data, [Any], null: false
  end
end
