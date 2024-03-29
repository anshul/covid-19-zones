# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 2.7.1"

gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 4.1"
gem "rails", "~> 6.0", ">= 6.0.3.1"

gem "bcrypt", "~> 3.1.7"
gem "image_processing", "~> 1.2"
gem "jbuilder", "~> 2.7"
gem "redis", "~> 4.0"
gem "sass-rails", ">= 6"
gem "sassc", "2.1.0" # Locked for pre-compiled sass
gem "webpacker", "~> 4.0"

gem "bootsnap", ">= 1.4.2", require: false

gem "aws-sdk-cloudwatch", "~> 1.38"
gem "marginalia", "~> 1.8"
gem "pg_query", "~> 1.2"
gem "pghero", "~> 2.5"

gem "awesome_print", "~> 1.8"
gem "deepsort", "~> 0.4.5"
gem "hashdiff", "~> 1.0", ">= 1.0.1"

gem "activeadmin", "~> 2.7"
gem "activeadmin_addons", git: "https://github.com/platanus/activeadmin_addons.git", ref: "60ddc29"
gem "google_drive", "~> 3.0", ">= 3.0.4"
gem "graphiql-rails"
gem "graphql", "~> 1.10"
gem "graphql-batch", "~> 0.4.2"
gem "octokit", "~> 4.18"
gem "rollbar", "~> 2.25"

gem "activerecord-import", "~> 1.0"
gem "cancancan", "~> 3.1"
gem "dalli", "~> 2.7", ">= 2.7.10"
gem "daru", "~> 0.2.2"
gem "devise", "~> 4.7", ">= 4.7.1"
gem "devise-jwt", "~> 0.6.0"
gem "excon", "~> 0.73.0"
gem "jwt", "~> 2.2", ">= 2.2.1"
gem "omniauth-google-oauth2", "~> 0.8.0"
gem "rack-cors", "~> 1.0", ">= 1.0.3"
gem "slim-rails", "~> 3.2"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "pry-rails", "~> 0.3.9"
  gem "rubocop", "~> 0.81.0", require: false
  gem "rubocop-rails", "~> 2.5", ">= 2.5.2", require: false
  gem "solargraph", "~> 0.38.6", require: false

  gem "guard", "~> 2.16", ">= 2.16.2", require: false
  gem "guard-minitest", "~> 2.4", ">= 2.4.6", require: false

  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring", "~> 2.1"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver", "~> 3.142", ">= 3.142.7"
  gem "webdriver", "~> 0.5.0"

  gem "minitest-focus", "~> 1.1"
  gem "minitest-reporters", "~> 1.4", ">= 1.4.2"
  gem "vcr", "~> 5.1"
  gem "webmock", "~> 3.8", ">= 3.8.3"
end

gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
