# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root to: "single_page_app#index"

  get "/v1/zones", to: "zones#index", as: :zones_list

  get "*path", to: "single_page_app#index", as: :single_page_app, constraints: lambda { |req|
    req.path.exclude? "rails/active_storage"
  }
end
