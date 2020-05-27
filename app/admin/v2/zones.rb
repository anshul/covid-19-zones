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

  batch_action :publish do |ids|
    zone_to_publish = batch_action_collection.find(ids)
    errors = []
    zone_to_publish.filter { |zone| zone.published_at.nil? }.each do |zone|
      cmd = ::V2::RecordFact.new(details: { published_by: current_user.email }, entity_type: "unit", entity_slug: zone.code, fact_type: :zone_published)
      errors << "#{zone.name}: #{cmd.error_message}" unless cmd.call
    end

    message = "#{zone_to_publish.count - errors.count} zones were published."
    message += " #{errors.count} failed (#{errors.slice(..2).join(', ')} ...)" if errors.present?
    flash = errors.present? ? { alert: message } : { notice: message }

    redirect_to collection_path, **flash
  end

  batch_action :unpublish do |ids|
    zone_to_unpublish = batch_action_collection.find(ids)
    errors = []
    zone_to_unpublish.filter { |zone| zone.published_at.present? }.each do |zone|
      cmd = ::V2::RecordFact.new(details: { unpublished_by: current_user.email }, entity_type: "unit", entity_slug: zone.code, fact_type: :zone_unpublished)
      errors << "#{zone.name}: #{cmd.error_message}" unless cmd.call
    end

    message = "#{zone_to_unpublish.count - errors.count} zones were unpublished."
    message += " #{errors.count} failed (#{errors.slice(..2).join(', ')} ...)" if errors.present?
    flash = errors.present? ? { alert: message } : { notice: message }

    redirect_to collection_path, **flash
  end

  actions :index, :show, :new, :create
  index do
    selectable_column
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
      row("published?") { |b| status_tag b.published_at.present? }
      row :published_at
      row :created_at
    end
  end

  form do |f|
    f.inputs "Zone Details" do
      f.input :name
      f.input :category, as: :select, collection: ::V2::Zone::CATEGORIES
      f.input :parent
      f.input :md
      f.input :owner

      f.input :units, as: :select, multiple: true, collection: ::V2::Unit.all.pluck(:name, :code)
    end
    f.actions
  end

  controller do
    def create; end
  end

  filter :published_at_present, label: "published", as: :boolean
  filter :code
  filter :name
  filter :maintainer, as: :select, collection: -> { ::V2::Zone.distinct.pluck(:maintainer) }
end
