# frozen_string_literal: true

class Country < Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
end
