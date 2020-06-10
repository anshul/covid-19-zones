# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql" if Rails.env.development?
  post "/graphql", to: "graphql#execute"

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: "single_page_app#index"
  authenticate :user do
    mount PgHero::Engine, at: "pghero"
  end

  scope "api/", format: :json do
    get "/maps", to: "maps#show", as: :maps_show
    get "/zones", to: "zones#index", as: :zones_list
    get "/zone", to: "zones#show", as: :zone_show
    get "*path", to: "single_page_app#api_not_found", as: :api_not_found
  end

  get "*path", to: "single_page_app#index", as: :single_page_app
end
