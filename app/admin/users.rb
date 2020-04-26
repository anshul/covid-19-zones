# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :email, :role, :name, :github_handle, :twitter_handle, :password, :password_confirmation
  actions :all, except: [:destroy]
  menu priority: 5

  index do
    selectable_column
    id_column
    column :name
    column :role
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end
  show do
    attributes_table do
      row :name
      row :role
      row :email
      row :current_sign_in_at
      row :sign_in_count
      row :created_at
    end
    active_admin_comments
  end

  filter :name
  filter :email
  filter :role, as: :select, collection: ::User::ROLES
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :role, as: :select, collection: ::User::ROLES.map { |r| [r, r] }
      f.input :github_handle, hint: "without the @"
      f.input :twitter_handle, hint: "without the @"
    end
    f.actions
  end
end
