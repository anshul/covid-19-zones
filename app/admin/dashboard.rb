# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span  "Hello contributors!"
        small "You can manipulate the published data here..."
      end
    end

    columns do
      #   column do
      #     panel "Recent Posts" do
      #       ul do
      #         Post.recent(5).map do |post|
      #           li link_to(post.title, admin_post_path(post))
      #         end
      #       end
      #     end
      #   end

      column do
        panel "Info" do
          para "Origin -> a source of time series"
          para "Snapshot -> a time series of a particular type"
          para "Unit -> a geographical area to which snapshots can publish time series"
          para "Zone -> a geographical collection of units that are visible on the front end and have a page"
        end
      end
    end
  end # content
end
