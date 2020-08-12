# Heroku Deployment with Postgres

## Introduction
In this guide, we will
- install and use PostgreSQL instead of SQLite3
- deploy our application to heroku

## Prerequisites
- Heroku CLI ([view installation details](https://devcenter.heroku.com/articles/getting-started-with-ruby#set-up))
- Postgresql ([view installation details](https://devcenter.heroku.com/articles/heroku-postgresql#local-setup))

## Adding Postgres

In the Gemfile, replace the line starting with `gem 'sqlite3'` with `gem 'pg'`.

Make sure to run `bundle install` afterwards and replace the contents of `config/database.yml` with

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development

test:
  <<: *default
  database: myapp_test

production:
  <<: *default
  database: myapp_production
  username: myapp
  password: <%= ENV['MYAPP_DATABASE_PASSWORD'] %>
```