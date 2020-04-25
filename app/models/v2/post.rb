# frozen_string_literal: true

module V2
  class Post < ApplicationRecord
    belongs_to :zone, class_name: "V2::Zone", foreign_key: "zone_code", primary_key: "code", inverse_of: :posts
    belongs_to :unit, class_name: "V2::Unit", foreign_key: "unit_code", primary_key: "code", inverse_of: :posts
  end
end
