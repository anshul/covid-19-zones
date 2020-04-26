# frozen_string_literal: true

ActiveAdmin.register ::V2::Origin do
  permit_params :name, :attribution_text
  menu label: "Origins (v2)", priority: 100
  scope :all, default: true

  actions :index, :show, :edit, :update
  index do
    column :code do |origin|
      link_to origin.name, v2_v2_origin_path(origin)
    end
    column :snapshots do |origin|
      link_to "#{origin.snapshots.count} snapshots", v2_v2_snapshots_path(q: { origin_code_eq: origin.code })
    end
    column :attribution_text
    column :source_name
    column :source_subname
    column :data_category
    actions
  end

  form do |f|
    f.inputs do
      f.input :code, input_html: { readonly: true, disabled: true }
      f.input :name
      f.input :attribution_text
      f.input :source_name
      f.input :source_subname
      f.input :source_url, input_html: { readonly: true, disabled: true }
      f.input :md, label: "Display markdown", as: :text
    end
    f.actions
  end

  filter :code
end
