# frozen_string_literal: true

ActiveRecord::Base.logger = nil if Rails.env.production?
::ImportUsers.perform_task
::ImportWiki.perform_task
::ImportV2.perform_task
::ImportOrigins.perform_task
::V2::SeedOverrides.perform_task
