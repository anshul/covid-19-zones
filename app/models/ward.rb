# frozen_string_literal: true

class Ward < Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
  validates :parent_zone, format: %r{\A[a-z0-9\-_]+/[a-z0-9\-_]+/[a-z0-9\-_]+/[a-z0-9\-_]+\z}
  validates :code, format: %r{\A[a-z0-9\-_]+/[a-z0-9\-_]+/[a-z0-9\-_]+/[a-z0-9\-_]+/[a-z0-9\-_]+\z}

  alias_attribute :parent, :city

  belongs_to :city, foreign_key: "parent_zone", primary_key: "code", inverse_of: :wards

  def children
    []
  end

  def self.parent_klass
    ::City
  end
end
