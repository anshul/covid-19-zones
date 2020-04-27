# frozen_string_literal: true

ActiveAdmin.register ::V2::Zone do
  menu label: "Zones (v2)", priority: 10
  includes :cache, :units, :parent, :owner
  config.sort_order = "cumulative_infections_desc"

  scope :all, default: true do |zones|
    zones.joins(:cache)
  end

  ::V2::Zone::CATEGORIES.each do |cat|
    scope cat.capitalize, group: :category do |zones|
      zones.joins(:cache).where(category: cat)
    end
  end

  actions :index, :show
  index do
    column :code do |zone|
      link_to zone.code, v2_v2_zone_path(zone)
    end
    column :totals, sortable: "cumulative_infections" do |zone|
      zone.cache ? link_to(%i[cumulative_infections cumulative_recoveries cumulative_fatalities].map { |f| zone.cache[f] }.join(", "), v2_zone_computation_path(zone.cache)) : nil
    end
    column :name
    column :aliases
    column :category do |zone|
      zone.category.capitalize
    end
    column :maintainer, &:owner
    column :parent do |zone|
      zone.parent ? link_to(zone.parent_code, v2_v2_zone_path(zone.parent)) : nil
    end
    column :published do |zone|
      !!zone.published_at
    end
    column :units, &:units
    actions
  end
  show do
    attributes_table do
      row :code
      row :name
      row :aliases
      row :parent
      row :units
      row :owner
      row "computations" do |zone|
        zone.cache ? link_to("Computations: " + ::V2::Zone::FIELDS.map { |f| zone.cache[f].to_s + " #{f.to_s.split('_').last}" }.join(", "), v2_zone_computation_path(zone.cache)) : nil
      end
      row :published_at
      row :created_at
    end
  end

  filter :published_at_present, label: "published", as: :boolean
  filter :code
  filter :name
  filter :maintainer, as: :select, collection: -> { ::V2::Zone.distinct.pluck(:maintainer) }
end
