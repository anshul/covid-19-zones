# frozen_string_literal: true

class District < Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
  validates :parent_zone, format: %r{\A[a-z\-]+/[a-z\-]+\z}
  validates :code, format: %r{\A[a-z\-]+/[a-z\-]+/[a-z\-]+\z}

  alias_attribute :children, :cities
  alias_attribute :parent, :state

  belongs_to :state, foreign_key: "parent_zone", primary_key: "code", inverse_of: :districts
  has_many :cities, -> { order(code: :asc) }, foreign_key: "parent_zone", primary_key: "code", dependent: :delete_all, inverse_of: :district

  def self.parent_klass
    ::State
  end
end
