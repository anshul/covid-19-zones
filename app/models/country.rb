# frozen_string_literal: true

class Country < Zone
  validates :slug, :code, :type, :name, presence: true
end
