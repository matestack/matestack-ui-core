# Core Contribution

We are very happy about anyone that wants to improve this project! Please make sure to read this guide before starting your work to avoid unnecessary trouble down the road! Always feel welcomed to reach out to us via [Discord](https://discord.gg/c6tQxFG) or mail if you are unsure or need further information.

## What to work on

If you want to contribute and are unsure what to work on, take a look at the [open issues!](https://github.com/matestack/matestack-ui-core/issues)

Other case: You plan to built something that you think should be part of the Matestack UI Core \(or you have already built it\)? Great, then open a pull request and we will take a look!

## How to contribute

Please create a pull request to the `develop` branch with your tested and documented code. Bonus points for using our PR template!

## Documentation

Documentation can be found in the `/docs/*` folder. Please make sure to cover basic use cases of your concepts & components for other users! Feel free to take a look at other examples and copy their structure!

Note: We will not approve pull requests that introduce new concepts or components without documentation. Same goes for existing concepts & components. If you change the behavior of an existing part of this project, make sure to also update the corresponding part of the documentation!

## Dockerized Core Dev

We dockerized the core development in order to make it as convenient as possible to contribute to `matestack-ui-core`.

You will need to install docker and docker-compose:

* [Install Docker on Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-convenience-script)
* [Install docker-compose](https://docs.docker.com/compose/install/)

### Setup Database and Yarn Packages

In order to migrate the database and install yarn packages, do:

```text
docker-compose run --rm dummy bundle exec rake db:setup
docker-compose run --rm dummy yarn install
docker-compose run --rm dummy sh -c "cd builder && yarn install"
docker-compose run --rm dummy sh -c "cd spec/dummy && yarn install"
```

If you already created sqlite files locally in `spec/dummy/db`, the command `docker-compose run --rm dummy bundle exec rake db:migrate` will fail. Please remove the locally created sqlite files and rerun `docker-compose run --rm dummy bundle exec rake db:migrate`

You might need to redo these steps if new migrations or yarn packages are added/updated.

### Run the Dummy App

The dummy app provides a good playground for matestacks core development. The source code can be found and manipulated \(be careful what you commit\) at `spec/dummy`. Run it like seen below:

```text
docker-compose up dummy
```

Visit `localhost:3000/sandbox/hello` in order to visit the sandbox page. It lives in `spec/dummy/app/matestack/pages/sandbox/hello.rb`. Feel free to modify it and play around with components and concepts. Just don't push your local changes to the remote repo.

Visit `localhost:3000/my_app/my_first_page` in order to visit some example use cases. The pages live in `spec/dummy/app/matestack/pages/my_app`.

### Run the Webpack Watcher

The builder app located in `builder/` uses webpacker in order build matestacks Javascript based on the source code found in `app/`. During development it can be used to compile the JavaScript when any relevant source code is changed. Run it like seen below:

```text
docker-compose up webpack-watcher
```

### Run bundle/yarn install in a Docker container

In order to execute commands such as `bundle install`, `yarn install` you need to run:

```text
docker-compose run --rm dummy bundle install
docker-compose run --rm dummy yarn install
docker-compose run --rm dummy sh -c "cd spec/dummy && yarn install"
```

### Run commands as your user in a Docker container

When running commands, which generates files, which then are mounted to your host filesystem, you need to tell the Docker container that it should run with your user ID.

```text
CURRENT_UID=$(id -u):$(id -g) docker-compose run --rm dummy bash

#and then your desired command such as:

rails generate matestack:core:component div
```

Otherwise the generated files will be owned by the `root` user and are only writeable when applying `sudo`.

**Note:** `bundle install` and `yarn install` can't be executed inside the Docker container as the current user. `CURRENT_UID=$(id -u):$(id -g) docker-compose run --rm dummy bundle install` will not work.

## Core Components Generator

```bash
CURRENT_UID=$(id -u):$(id -g) docker-compose run --rm dummy bash
rails generate matestack:core:component div
```

This will create a component for the HTML `<div>` tag and will generate the following files:

```bash
app/concepts/matestack/ui/core/div/div.haml
app/concepts/matestack/ui/core/div/div.rb
spec/usage/components/div_spec.rb
docs/components/div.md
```

## Dockerized Test Env

```bash
bundle install
yarn install
cd spec/dummy
yarn install # dependencies for the dummy app in testing
cd ../..

bundle exec rake db:create
bundle exec rake db:schema:load
```

## Tests

To assure this project is and remains in great condition, we heavily rely on automated tests. Tests are defined in `/spec` folder and can be executed by running:

```bash
docker-compose run --rm test bash
bundle exec rake db:setup #once initially
bundle exec rspec spec/usage/components
```

Tests follow quite the same rules as the documentation: Make sure to either add relevant tests \(when introducing new concepts or components\) or change existing ones to fit your changes \(updating existing concepts and components\). Pull requests that add/change concepts & components and do not come with corresponding tests will not be approved.

## Core Components

Core Components are an essential part of the `matestack-ui-core` gem. If you are planning to contribute to Matestack you can start doing that by creating a core component. To help you getting started you can use the Core Component Generator.

The generator will create a matestack core component to `app/concepts/matestack/ui/core`.

Example:

```bash
rails generate matestack:core:component div
```

This will create a component for the HTML `<div>` tag and will generate the following files:

```bash
app/concepts/matestack/ui/core/div/div.haml
app/concepts/matestack/ui/core/div/div.rb
spec/usage/components/div_spec.rb
docs/components/div.md
```

## Release

[Webpacker](https://github.com/rails/webpacker) is used for managing all JS assets. In order to create production-ready assets, run the [task](https://github.com/matestack/matestack-ui-core/blob/master/Rakefile)

```text
docker-compose run --rm webpack-watcher bash
cd builder
bundle exec rails webpacker:compile RAILS_ENV=production
```

The assets will be exported to [`vendor/assets/javascripts/dist`](https://github.com/matestack/matestack-ui-core/tree/master/vendor/assets/javascripts/dist).

Under the hood, we use a "builder" app in the [`builder`](https://github.com/matestack/matestack-ui-core/tree/master/builder) folder in order to run webpacker and create the assets. Its webpack\(er\) configuration can be found in [`builder/config`](https://github.com/matestack/matestack-ui-core/tree/master/builder/config).

When creating a new matestack-ui-core release, make sure to also change the version number accordingly in [`package.json`](https://github.com/matestack/matestack-ui-core/blob/master/package.json) and to create a corresponding [version tag on github](https://github.com/matestack/matestack-ui-core/tags).

