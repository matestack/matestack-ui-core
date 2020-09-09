# Essential Guide 12: Heroku Deployment with Postgres

Demo: [Matestack Demo](https://demo.matestack.io)<br>
Github Repo: [Matestack Demo Application](https://github.com/matestack/matestack-demo-application)

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

<details>
<summary>Note for Linux/Ubuntu users</summary>
You may need to install additional libraries by running <br/>
<code>sudo apt-get -y install postgresql postgresql-contrib libpq-dev</code>
instead of only running <br/>
<code>sudo apt-get install postgresql</code>.
</details>
<br/>

<details>
<summary>Note for postgres role error</summary>
If you get an error from postgres stating that your role is missing add it by creating a user. To do so run below codesnippet. <br/>
<code>sudo su - postgres && createuser -s -r postgres</code>
</details>
<br/>

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

## Deployment

To set up a new heroku project, run

```sh
heroku create
```

followed by

```sh
git push heroku master
```

to trigger a deployment.
When we have new migrations or didn't initialize the database yet, we need to run

```sh
heroku run rails db:migrate
```

In an earlier guide we added some persons with seeds to our local database. In order to also seed some persons into our production database on heroku we need to run

```sh
heroku run rake db:seed
```

After the deployment, our database migrate and seeds task successfully finished we can visit our deployed application by running `heroku open`.

If you have used assets like we did in our application remember to run `heroku run rails assets:precompile`.

## Creating an admin

In order to be able to login, we need to create an admin. We could add one in our seeds but we wouldn't recommend doing it. Instead we can use another of herokus features. Opening a rails console connected with the production database of our live application.

```
heroku run rails console
```

After the console opened we can now create an admin using the `create` method of our `Admin` model with an email, password and password confirmation as parameters.

```ruby
Admin.create(email: 'admin@example.com', password: 'OnlyForSuperMates', password_confirmation: 'OnlyForSuperMates')
```

Now we can close the console and run `heroku open` again. We can now login to our admin app with the above specified credentials.

## Recap & outlook

We successfully deployed our application to heroku and learned what are the necessary steps to do this. We also switched our application database from sqlite to postgres, because heroku doesn't support sqlite.

While the application is good as it is right now, go ahead and check out the [last part of the essential guide](/docs/guides/2-essential/13_wrap_up.md).
