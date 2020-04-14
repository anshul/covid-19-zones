# frozen_string_literal: true

class ZonesController < ApplicationController
  def index
    zones = Zone.where(parent_zone: params[:parent_code])
    render status: :ok, json: { zones: zones.as_json(only: Zone.view_attrs) }
  end

  def show
    zone_code = params[:slug].split("/").reject { |part| part == "unknown" }.join("/")
    per_day_counts = Patient.where("zone_code like ?", "#{zone_code}/%").group(:announced_on).count

    render status: :ok, json: {
      perDayCounts: per_day_counts.sort_by { |announced_on, _| announced_on }.map { |announced_on, count| { x: announced_on.strftime("%b %d"), y: count } }
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
