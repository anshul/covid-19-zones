# Covid-19-zones


## Recommended local setup

* Ruby version - [2.7.0](.tool-versions)
* Node version - [13.12.0](.tool-versions)
* System dependencies
  - postgresql, redis, yarn
  - [heroku-cli](https://devcenter.heroku.com/articles/heroku-cli)
* Create a pg user called covid_19_zones with password covid_19_zones - `createuser -d -s -P covid_19_zones`
* Install gems - `bundle install --path=.bundle --jobs=4 --retry=3`
* Install node modules - `yarn`
* Setup db - `bundle exec rails db:create db:migrate db:seed`
* Start the server using heroku cli and Procfile.local - `bin/start-server`
* Run tests - `bundle exec rails test`
* Autorun tests - `bundle exec guard`
* Fix style issues before commits - `bundle exec rubocop -a` (or to run it on only the git cache - `bundle exec rubocop -a -D $(git diff --cached --name-only --diff-filter=d HEAD | egrep ".(rb|rake)$" | egrep -v "db\/schema.rb" | egrep -v "lib\/pb") Gemfile`)
