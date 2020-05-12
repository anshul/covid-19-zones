# frozen_string_literal: true

class SinglePageAppController < ApplicationController
  def index; end

  def api_not_found
    render status: :not_found, json: { message: "No such api" }
  end
end
