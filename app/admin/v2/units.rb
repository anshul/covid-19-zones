# frozen_string_literal: true

ActiveAdmin.register ::V2::Unit do
  menu label: "Units (v2)", priority: 2
  scope :all, default: true
  includes :zones, :parent, :owner, streams: :origin

  ::V2::Unit::CATEGORIES.each do |cat|
    scope cat.capitalize, group: :category do |units|
      units.where(category: cat)
    end
  end

  actions :index, :show
  index do
    column :code do |unit|
      link_to unit.code, v2_v2_unit_path(unit)
    end
    column :name
    column :population do |unit|
      "#{number_to_human(unit.population)} (#{unit.population_year})"
    end
    column :area, sortable: :area_sq_km do |unit|
      "#{unit.area_sq_km} ㎢"
    end
    column :category do |unit|
      unit.category.capitalize
    end
    column :maintainer, &:owner
    column :parent do |unit|
      unit.parent ? link_to(unit.parent_code, v2_v2_unit_path(unit.parent)) : nil
    end
    column :zones, &:zones
    column :streams, &:streams
    actions
  end

  filter :code
  filter :name
  filter :population
  filter :population_year
  filter :maintainer, as: :select, collection: ::V2::Unit.distinct.pluck(:maintainer)
end
