# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  before_action :configure_current_env

  protected

  def current_env
    ::Project.env
  end

  def configure_current_env
    render text: "Invalid PROJECT_ENV=#{Project.env.inspect} for RACK_ENV=#{Rails.env}" unless Project.valid_environment?
  end

  def t_now
    @t_now ||= Time.zone.now
  end
end
