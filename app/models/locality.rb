# frozen_string_literal: true

class Locality < Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
end
