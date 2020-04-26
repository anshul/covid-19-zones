# frozen_string_literal: true

ActiveAdmin.register ::V2::Zone do
  menu label: "Zones (v2)", priority: 2
  scope :all, default: true

  ::V2::Zone::CATEGORIES.each do |cat|
    scope cat.capitalize, group: :category do |zones|
      zones.where(category: cat)
    end
  end

  actions :index, :show
  index do
    column :code do |zone|
      link_to zone.code, v2_v2_zone_path(zone)
    end
    column :name
    column :aliases
    column :category do |zone|
      zone.category.capitalize
    end
    column :maintainer
    column :parent do |zone|
      zone.parent ? link_to(zone.parent_code, v2_v2_zone_path(zone.parent)) : nil
    end
    column :published do |zone|
      !!zone.published_at
    end
    column :units, &:units
    actions
  end

  filter :published_at_present, label: "published", as: :boolean
  filter :code
  filter :name
  filter :maintainer, as: :select, collection: ::V2::Zone.distinct.pluck(:maintainer)
end
