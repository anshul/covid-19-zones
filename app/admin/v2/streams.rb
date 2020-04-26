# frozen_string_literal: true

ActiveAdmin.register ::V2::Stream do
  menu label: "Streams (v2 time series)", priority: 3
  scope :all, default: true

  ::V2::Stream::CATEGORIES.each do |cat|
    scope cat.capitalize, group: :category do |streams|
      streams.where(category: cat)
    end
  end

  actions :index, :show
  index do
    column :code do |stream|
      link_to stream.name, v2_v2_stream_path(stream)
    end
    column :dated do |stream|
      stream.dated.strftime("%b %d")
    end
    column :cumulative_count do |stream|
      stream.cumulative_count.to_i
    end
    column :series, sortable: :max_count do |stream|
      "#{stream.min_count.to_i} - #{stream.max_count.to_i}"
    end
    column :length, sortable: :min_date do |stream|
      distance_of_time_in_words(stream.min_date, stream.max_date + 1.day)
    end
    column :category do |stream|
      stream.category.capitalize
    end
    column :unit
    column :origin
    column :snapshot
    column :downloaded_at
    column :attribution_md
    actions
  end

  filter :code
  filter :unit_code
  filter :cumulative_count
  filter :min_count
  filter :max_count
  filter :min_date
  filter :max_date
  filter :downloaded_at
  filter :attribution_md
end
