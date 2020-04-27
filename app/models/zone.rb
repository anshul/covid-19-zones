# frozen_string_literal: true

class Zone < ApplicationRecord
  validates :slug, :code, :type, presence: true

  has_many :taggings, as: :taggable, dependent: :destroy
  FIELDS = %i[cumulative_infections cumulative_recoveries cumulative_fatalities cumulative_tests current_actives].freeze

  ALIASES = {
    "Delhi".parameterize                       => %w[delhi new-delhi],
    "Ahmadabad".parameterize                   => %w[ahmedabad],
    "Bengaluru".parameterize                   => %w[bengaluru bangalore bangalore-urban],
    "Andaman and Nicobar Islands".parameterize => %w[andaman-and-nicobar]
  }.freeze

  def self.named(parent_zone:, name:)
    @named ||= {}
    return other(parent_zone: parent_zone) unless valid_name?(name)

    name = name.to_s.strip
    key = "#{parent_zone}>#{name}"
    @named[key] ||= find_by(parent_zone: parent_zone, search_name: ALIASES[name.parameterize] || name.parameterize)
  end

  def self.named_or_new(parent_zone:, name:)
    model = named(parent_zone: parent_zone, name: name)
    return model if model
    return other(parent_zone: parent_zone) unless valid_name?(name)

    parent_model = parent_klass.find_by(code: parent_zone)
    key = "#{parent_zone}>#{name}"
    model = new(parent_zone: parent_zone, code: "#{parent_model.code}/#{name.parameterize}", slug: "#{parent_model.slug}/#{name.parameterize}", name: name.strip, search_name: name.parameterize)
    model.save!
    @named[key] = model
  end

  def self.other(parent_zone:)
    model = self["#{parent_zone}/other"]
    return model if model

    parent_model = parent_klass.find_by(code: parent_zone)
    raise "#{self}.other -> #{parent_zone} not found" unless parent_model

    model = new(parent_zone: parent_zone, code: "#{parent_model.code}/other", slug: "#{parent_model.slug}/other", name: "Other", search_name: "other")
    model.save!
    model
  end

  def self.valid_name?(name)
    name.to_s.downcase =~ /[a-z]/ && name.to_s.strip.parameterize != "other"
  end
end
