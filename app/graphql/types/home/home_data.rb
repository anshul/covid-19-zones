# frozen_string_literal: true

module Types
  module Home
    class HomeData < Types::BaseObject
      field :cases, ::Types::Home::Cases.connection_type, null: false
    end
  end
end
