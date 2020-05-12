# frozen_string_literal: true

class MapsController < ApplicationController
  def show
    query = GetMapData.new(codes: params[:codes].to_s.split(","))
    if query.run
      render status: :ok, json: query.result
    else
      render status: :bad_request, json: { message: query.error_message }
    end
  end

  private

  def show_params
    params.permit(:codes)
  end
end
