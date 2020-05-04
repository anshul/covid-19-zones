# frozen_string_literal: true

class ZonesController < ApplicationController
  def index
    zones = ::V2::Zone.where(parent: params[:parent_code])
    render status: :ok, json: { zones: zones.as_json(only: Zone.view_attrs) }
  end

  def show
    query = GetZoneData.new(code: params[:code])
    if query.run
      render status: :ok, json: query.result
    else
      render status: :bad_request, json: { message: query.error_message }
    end
  end

  private

  def index_params
    params.permit(:parent_code)
  end

  def show_params
    params.permit(:code)
  end
end
