# frozen_string_literal: true

class City < Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
end
