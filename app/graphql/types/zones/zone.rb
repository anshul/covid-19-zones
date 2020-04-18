# frozen_string_literal: true

module Types
  module Zones
    class Zone < Types::BaseObject
      field :slug, String, null: false
      field :code, String, null: false
      field :name, String, null: false
      field :search_name, String, null: true
      field :parent_zone, ::Types::Zones::Zone, null: true
      field :zone_md, String, null: true
      field :pop, String, null: true
      field :area, String, null: true
      field :density, String, null: true

      def parent_zone
        ::RecordLoader.for(::Zone, column: "code").load(object[:parent_zone])
      end
    end
  end
end
