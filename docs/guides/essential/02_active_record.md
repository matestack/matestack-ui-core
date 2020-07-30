# Essential Guide 2: ActiveRecord & Database
Welcome to the second part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
In the [previous guide](guides/essential/01_setup.md), we created a new project, installed the necessary libraries, added a demo `matestack` app featuring two `matestack` pages, and deployed it using Heroku.

In this guide, we will
- create an ActiveRecord model to work with throughout this series
- add some seeded data and migrate the database
- deploy the changes to the publicly running Heroku application

## Prerequisites
We expect you to have successfully finished the [previous guide](guides/essential/01_setup.md) and no uncommited changes in your project.

## Adding the ActiveRecord model
First, we need to create an ActiveRecord model and add the corresponding table to the database. This is quickly achieved by running

```sh
rails generate model Person first_name:string last_name:string role:integer
```

in the terminal. After the command has finished, you should see a new migration in `db/migrations/` and a newly added model in `app/models/person.rb`. To then apply those changes, you need to run

```sh
rake db:migrate
```

which should update the database schema in `db/schema.rb`.

## Updating the model, adding seeds and displaying app
To make use of the `role`-enum we already prepared in the database, update `app/models/person.rb` to look like this:

```ruby
class Person < ApplicationRecord
	enum role: [:client, :partner, :staff]
end
```

Great! Now, let's populate the database with some "fake" persons. Therefor, add the following content to `db/seeds.rb`:

```ruby
seeded_persons = [
	{first_name: 'Harris', last_name: 'Bees', role: :client},
	{first_name: 'Abigail', last_name: 'Salte', role: :client},
	{first_name: 'Woodrow', last_name: 'Trembly', role: :client},
	{first_name: 'Murray', last_name: 'Fedorko', role: :client},
	{first_name: 'Michaele', last_name: 'Kritikos', role: :client},
	{first_name: 'Sammie', last_name: 'Scovill', role: :client},
	{first_name: 'Xavier', last_name: 'Accosta', role: :partner},
	{first_name: 'Otis', last_name: 'Morro', role: :partner},
	{first_name: 'Omer', last_name: 'Ottman', role: :partner},
	{first_name: 'Marlo', last_name: 'Yousko', role: :staff},
	{first_name: 'Manuel', last_name: 'Venn', role: :staff}
]

seeded_persons.each do |person|
	Person.create(person)
end
```

and run

```sh
rake db:seed
```

to add those first persons to the database!

To finish things up for now, let's display all the new persons within the `matestack` app! To achieve this, update the contents of `app/matestack/demo/app.rb` to look like this:

```ruby
class Demo::App < Matestack::Ui::App

  def prepare
    @persons = Person.all
  end

  def response
    header do
      heading size: 1, text: 'Demo App'
      transition path: :first_page_path, text: 'First page'
      br
      transition path: :second_page_path, text: 'Second page'
    end
    main do
      page_content
      ul do
        @persons.each do |person|
          li do
            plain person.first_name
            strong text: person.last_name
          end
        end
      end
    end
  end

end
```

What happens here? In the `prepare`-statement, you're fetching all the person instances from your database, and within the `main`-tag each person's name gets displayed (last names in **bold** for extra emphasis) inside an unordered list (`ul`). Run `rails s` and head over to [localhost:3000](http://localhost:3000/) to check the result!

Of course, this is a very basic approach that we will iterate upon in the following parts of this guide series!

## Saving the status quo
As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add . && git commit -m "Introduce person model including seeds, add it to matestack/demo/app.rb"
```

## Deployment
After you've finished all your changes and commited them to Git, trigger another deployment via

 ```sh
 git push heroku master
 ```

to publish your changes. If you visit your site now, you will find that it is broken! But no worries, this is easily fixed: This time, since we've changed the schema in the database, we also need to take an extra step and migrate the database by running

```sh
heroku run rake db:migrate
```

After the migration finished successfully, your site is available again, but there's no visible change - there are no persons in the database yet. To change this, trigger the seeds by running

```sh
heroku run rake db:seed
```

Finally, you should be able to check the changes via

```sh
heroku open
```

and see a list of all the persons in your database - nice!

## Recap & outlook
We have updated the app to use a working database model, added some dummy records and displayed them in the `matestack` app.

Let's continue and build even cooler stuff by heading directly to the [next part of the series](/guides/essential/03_index_show.md).
