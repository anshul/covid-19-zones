# frozen_string_literal: true

ActiveAdmin.register ::V2::Override do
  menu label: "Overrides (v2)", priority: 100
  includes :unit
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

  show do
    attributes_table do
      row :unit
      row :maintainer
    end
  end

  sidebar "Upload Overrides", only: :show do
    active_admin_form_for :override_details, url: upload_overrides_csv_v2_v2_override_path, method: :post do |f|
      f.inputs do
        f.input :csv, label: false, as: :file
        f.action :submit
      end
    end
  end

  member_action :upload_overrides_csv, method: :post do
    # file = params[:override_details][:csv]
    redirect_to resource_path(resource), alert: "Not Implemented"
  end

  filter :code
end
