# frozen_string_literal: true

ActiveAdmin.register ::V2::Override do
  menu label: "Overrides (v2)", priority: 100
  scope :all, default: true

  actions :index, :show
  index do
    column :code do |override|
      link_to override.code, v2_v2_override_path(override)
    end
    column :unit do |override|
      link_to override.unit.name, v2_v2_unit_path(override.unit)
    end
    actions
  end

  filter :code
end
