# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root to: "single_page_app#index"

  scope "api/", format: :json do
    get "/zones", to: "zones#index", as: :zones_list
    get "/zone/:code", to: "zones#show", as: :zone_show
  end

  get "*path", to: "single_page_app#index", as: :single_page_app
end
