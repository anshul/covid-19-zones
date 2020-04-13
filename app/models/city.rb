# frozen_string_literal: true

class City < Zone
  validates :slug, :code, :type, :name, presence: true
end
