# Essential Guide 2: ActiveRecord & Database
Welcome to the second part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
In the [previous guide](guides/essential/01_setup.md), we created a new project, installed the necessary libraries, added a demo `matestack` app featuring two `matestack` pages, and deployed it using Heroku.

In this guide, we will
- create an ActiveRecord model to work with throughout this series
- add some seeded data and migrate the database
- deploy the changes to the publicly running Heroku application

## Prerequisites
We expect you to have successfully finished the [previous guide](guides/essential/01_setup.md).

## Adding the ActiveRecord model
First, we need to create an ActiveRecord model and add the corresponding table to the database. This is quickly achieved by running

```sh
rails generate model Person first_name:string last_name:string role:integer
```

in the terminal. After the command has finished, you should see a new migration in `db/migrations/` and a newly added model `app/models/person.rb`. To then apply those changes, you need to run

```sh
rails db:migrate
```

which should update the database schema in `db/schema.rb`.

## Updating the model, adding seeds and displaying an index page
The `role` database field should represent different roles which we define as an enum in our person model. Update `app/models/person.rb` to look like this:

```ruby
class Person < ApplicationRecord
	enum role: [:client, :partner, :staff]
end
```

Great! Now, let's populate the database with some "fake" persons. Therefore add the following content to `db/seeds.rb`:

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
rails db:seed
```

to add those persons to the database!

To finish things up for now, let's display all the new persons on an index page inside our app! To achieve this, we add an index route for our person model in `routes.rb`.

```ruby
Rails.application.routes.draw do
  root to: 'demo#first_page' 
  get '/second_page' to: 'demo#second_page' 

  resources :persons, only: [:index]
end
```

After that we create the corresponding person controller in `app/controllers/person_controller.rb` which will handle the index action. The index action should render the persons index page which we will create afterwards. Do not forget to define the `matestack_app` which should be used as a layout.

```ruby
class PersonsController < ApplicationController
  matestack_app Demo::App

  def index
    render Demo::Pages::Persons::Index
  end

end
```

Now we create our person index page. Because it should be rendered inside our demo app, it belongs to the demo namespace and as a page under the pages section. So we create our person index page under `app/matestack/demo/pages/persons` with the name `index.rb`. This index page should render a list of all persons.

```ruby
class Demo::Pages::Persons::Index

  def prepare
    @persons = Person.all
  end

  def response
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
```

What happens in this page? Before calling the `response` method of a page, app or component the `prepare` method gets evaluated. In this case we fetch all the persons from the database and assign the result to the instance variable `@persons` in the `prepare` statement. Inside our response method we can access this instance variable and iterate over it to create _li_ tags containing the plain person first name and the lastname inside a _strong_ tag.

Run `rails s` and head over to [localhost:3000/persons/index](http://localhost:3000/persons/index) to check the result!

Of course, this is a very basic approach that we will iterate and improve in the following parts of this guide series!

## Saving the status quo
As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add . && git commit -m "Introduce person model including seeds, add it to matestack/demo/app.rb"
```

## Recap & outlook
We have updated the app to use a working database model, added some records and displayed them on an index page.

Let's continue and build even cooler stuff by heading directly to the [next part of the series](/guides/essential/03_index_show.md).
