# frozen_string_literal: true

class Country < Zone
  validates :slug, :code, :type, :name, presence: true
  validates :parent_zone, absence: true

  has_many :states, -> { order(code: :asc) }, foreign_key: "parent_zone", primary_key: "code", dependent: :delete_all, inverse_of: :country

  def parent
    nil
  end
  alias_attribute :children, :states
end
