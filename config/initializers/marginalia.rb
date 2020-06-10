# frozen_string_literal: true

Marginalia.application_name = "c19z"
Marginalia::Comment.components = %i[application controller action line] if Rails.env.development?
