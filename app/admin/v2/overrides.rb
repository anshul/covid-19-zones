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
      row :override_details do |override|
        div do
          a href: download_overrides_csv_v2_v2_override_path, style: "float: right" do
            button "Download"
          end
        end
        table_for override.override_details do
          column("unit") { |row| ::V2::Unit[row["unit_code"]] }
          column("date") { |row| ::Date.parse(row["date"]) }
          column "category"
          column "value"
        end
      end
    end
  end

  sidebar "Upload Overrides", only: :show do
    active_admin_form_for :override_details, url: upload_overrides_csv_v2_v2_override_path, method: :post do |f|
      f.inputs do
        f.input :csv, label: false, as: :file
        f.action :submit, label: "Upload CSV"
      end
    end
  end

  member_action :upload_overrides_csv, method: :post do
    cmd = ::V2::UploadUnitOverrides.new(override_code: resource.code, csv: params.dig(:override_details, :csv).read)

    if cmd.call
      redirect_to resource_path(resource), { notice: "Override uploaded" }
    else
      redirect_to resource_path(resource), { alert: "Error: #{cmd.error_message}" }
    end
  end

  member_action :download_overrides_csv, method: :get do
    headers = ::V2::Override::OVERRIDE_KEYS
    csv_file = CSV.generate(headers: true) do |csv|
      csv << headers

      resource.override_details.each do |row|
        csv << headers.map { |attr| row[attr.to_s] }
      end
    end

    send_data csv_file, filename: "overrides-#{resource.code}--#{Time.zone.today}.csv"
  end

  filter :code
end
