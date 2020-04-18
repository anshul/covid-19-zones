# frozen_string_literal: true

module Types
  class Any < Types::BaseScalar
    description "Represents an unconstrained type. No coercion is performed"

    def self.coerce_input(input_value, _context)
      input_value
    end

    def self.coerce_result(ruby_value, _context)
      ruby_value
    end
  end
end
