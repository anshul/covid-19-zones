# frozen_string_literal: true

class ZonesController < ApplicationController
  def index
    zones = Zone.where(parent_zone: params[:parent_code])
    render status: :ok, json: { zones: zones.as_json(only: Zone.view_attrs) }
  end

  def show
    zone_slug = params[:slug].split("/").reject { |part| part == "unknown" }.join("/")
    zone = Zone.find_by(slug: zone_slug)
    parent_zone = zone.parent
    per_day_counts = Patient.where("zone_code like ?", "#{zone.code}/%").group(:announced_on).count

    per_day_data = per_day_counts.sort_by { |announced_on, _| announced_on }.map { |announced_on, count| { date: announced_on.strftime("%b %d"), count: count } }

    average_computer = ->(group) { (group.map { |point| point[:count] }.sum / group.count.to_f).round(2) }
    three_day_moving_average = per_day_data.in_groups_of(3).select { |group| group.compact.count == group.count }.map do |group|
      { date: group.last[:date], count: average_computer.call(group) }
    end

    sibling_total_case_counts = Patient.where("zone_code like ?", "#{parent_zone&.code || zone.code}/%").group(:zone_code).count
    sibling_zones = parent_zone&.children&.as_json(only: Zone.view_attrs) || [zone.as_json(only: Zone.view_attrs)]
    sibling_zones = sibling_zones.map { |s_zone| s_zone.merge("total_cases" => sibling_total_case_counts.filter { |code| code.starts_with?(s_zone["code"]) }.map { |_, v| v }.sum) }

    point_formatter = ->(point) { { x: point[:date], y: point[:count] } }
    render status: :ok, json: {
      parentZone:            parent_zone.present? ? parent_zone.as_json(only: Zone.view_attrs) : nil,
      siblingZones:          sibling_zones.sort_by { |s_zone| -1 * s_zone["total_cases"] },
      perDayCounts:          per_day_data.map { |point| point_formatter.call(point) },
      threeDayMovingAverage: three_day_moving_average.map { |point| point_formatter.call(point) }
    }.deep_transform_keys { |k| k.to_s.camelize :lower }
  end

  private

  def index_params
    params.permit(:parent_code)
  end

  def show_params
    params.permit(:slug)
  end
end
