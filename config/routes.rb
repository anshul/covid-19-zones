# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root to: "single_page_app#index"
end
