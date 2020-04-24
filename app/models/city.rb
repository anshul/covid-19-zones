# frozen_string_literal: true

class City < Zone
  validates :slug, :code, :type, :name, :parent_zone, presence: true
  validates :parent_zone, format: %r{\A[a-z0-9\-_]+/[a-z0-9\-_]+/[a-z0-9\-_]+\z}
  validates :code, format: %r{\A[a-z0-9\-_]+/[a-z0-9\-_]+/[a-z0-9\-_]+/[a-z0-9\-_]+\z}
  alias_attribute :children, :wards
  alias_attribute :parent, :district

  belongs_to :district, foreign_key: "parent_zone", primary_key: "code", inverse_of: :cities
  has_many :wards, -> { order(code: :asc) }, foreign_key: "parent_zone", primary_key: "code", dependent: :delete_all, inverse_of: :city
  has_many :localities, -> { order(code: :asc) }, foreign_key: "parent_zone", primary_key: "code", dependent: :delete_all, inverse_of: :city

  def self.parent_klass
    ::District
  end
end
