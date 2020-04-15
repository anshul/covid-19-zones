# frozen_string_literal: true

class Locality < Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
  validates :parent_zone, format: %r{\A[a-z\-]+/[a-z\-]+/[a-z\-]+/[a-z0-9\-]+\z}
  validates :code, format: %r{\A[a-z\-]+/[a-z\-]+/[a-z\-]+/[a-z0-9\-]+/[a-z0-9\-]+\z}

  alias_attribute :parent, :city

  belongs_to :city, foreign_key: "parent_zone", primary_key: "code", inverse_of: :localities

  def children
    []
  end

  def self.parent_klass
    ::City
  end
end
