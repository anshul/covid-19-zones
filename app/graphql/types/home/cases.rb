# frozen_string_literal: true

module Types
  module Home
    class Cases < Types::BaseObject
      field :label, String, null: false
      field :name, String, null: false
      field :value, Int, null: false
    end
  end
end
