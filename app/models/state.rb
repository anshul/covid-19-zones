# frozen_string_literal: true

class State < Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
end
