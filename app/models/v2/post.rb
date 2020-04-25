# frozen_string_literal: true

module V2
  class Post < ApplicationRecord
    belongs_to :zone, class_name: "V2::Zone"
    belongs_to :unit, class_name: "V2::Unit"
  end
end
