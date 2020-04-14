# frozen_string_literal: true

class State < ::Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
  alias_attribute :children, :districts
  alias_attribute :parent, :country

  belongs_to :country, foreign_key: "parent_zone", primary_key: "code", inverse_of: :states
  has_many :districts, -> { order(code: :asc) }, foreign_key: "parent_zone", primary_key: "code", dependent: :delete_all, inverse_of: :state
end
