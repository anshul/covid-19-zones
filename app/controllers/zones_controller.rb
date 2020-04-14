# frozen_string_literal: true

class ZonesController < ApplicationController
  def index
    zones = Zone.where(parent_zone: params[:parent_code])
    render status: :ok, json: { zones: zones.as_json(only: Zone.view_attrs) }
  end

  private

  def index_params
    params.permit(:parent_code)
  end
end
