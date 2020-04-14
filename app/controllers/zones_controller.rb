# frozen_string_literal: true

class ZonesController < ApplicationController
  def index
    zones = Zone.where(parent_zone: params[:parent_code])
    render status: :ok, json: { zones: zones.as_json(only: Zone.view_attrs) }
  end

  def show
    zone_slug = params[:slug].split("/").reject { |part| part == "unknown" }.join("/")
    zone = Zone.find_by(slug: zone_slug)
    per_day_counts = Patient.where("zone_code like ?", "#{zone.code}/%").group(:announced_on).count

    per_day_data = per_day_counts.sort_by { |announced_on, _| announced_on }.map { |announced_on, count| { date: announced_on.strftime("%b %d"), count: count } }

    average_computer = ->(group) { (group.compact.map { |point| point[:count] }.sum / group.compact.count.to_f).round(2) }
    three_day_moving_average = per_day_data.in_groups_of(3).map do |group|
      { date: group.compact.last[:date], count: average_computer.call(group) }
    end

    point_formatter = ->(point) { { x: point[:date], y: point[:count] } }
    render status: :ok, json: {
      parentZone:            zone.parent.present? ? zone.parent.as_json(only: Zone.view_attrs) : nil,
      siblingZones:          zone.parent&.children&.as_json(only: Zone.view_attrs) || [zone.as_json(only: Zone.view_attrs)],
      perDayCounts:          per_day_data.map { |point| point_formatter.call(point) },
      threeDayMovingAverage: three_day_moving_average.map { |point| point_formatter.call(point) }
    }
  end

  private

  def index_params
    params.permit(:parent_code)
  end

  def show_params
    params.permit(:slug)
  end
end
