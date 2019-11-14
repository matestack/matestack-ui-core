# Core Contribution

We are very happy about anyone that wants to improve this project! Please make sure to read this guide before starting your work to avoid unnecessary trouble down the road!
Always feel welcomed to reach out to us via [Gitter](https://gitter.im/basemate/community) or mail if you are unsure or need further information.

## What to work on

If you want to contribute and are unsure what to work on, take a look at the [open issues!](https://github.com/basemate/matestack-ui-core/issues)

Other case: You plan to built something that you think should be part of the Matestack UI Core (or you have already built it)? Great, then open a pull request and we will take a look!

## How to contribute

Please create a pull request to the `develop` branch with your tested and documented code. Bonus points for using our PR template!


## Documentation

Documentation can be found in the `/docs` folder. Please make sure to cover basic use cases of your concepts & components for other users!
Feel free to take a look at other examples and copy their structure!

Note: We will not approve pull requests that introduce new concepts or components without documentation. Same goes for existing concepts & components.
If you change the behavior of an existing part of this project, make sure to also update the corresponding part of the documentation!

## Dockerized Core Dev

We dockerized the core development in order to make it as convenient as possible to contribute to matestack-ui-core.

You will need to install docker and docker-compose:

* [Install Docker on Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-convenience-script)
* [Install docker-compose](https://docs.docker.com/compose/install/)

### Setup Database and Yarn Packages

In order to migrate the database and install yarn packages, do:

```shell
docker-compose run --rm dummy rake db:migrate
docker-compose run --rm dummy yarn install
docker-compose run --rm dummy sh -c "cd spec/dummy && yarn install"
```

You might need to redo these steps if new migrations or yarn packages are added/updated.

### Run the Dummy App

The dummy app provides a good playground for matestacks core development. The source code can be found and manipulated (be careful what you commit) at `spec/dummy`. Run it like seen below:

```shell
docker-compose up dummy
```

### Run the Webpack Watcher

The builder app located in `builder/` uses webpacker in order build matestacks Javascript based on the source code found in `app/`. During development it can be used to compile the javascript when any relevant source code is changed. Run it like seen below:

```shell
CURRENT_UID=$(id -u):$(id -g) docker-compose up webpack-watcher
```

## Core Components

Core Components are an essential part of the `matestack-ui-core` gem.
If you are planning to contribute to Matestack you can start doing that by creating a core component. To help you getting started you can use the Core Component Generator.

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

## Tests

To assure this project is and remains in great condition, we heavily rely on automated tests. Tests are defined in `/spec` folder and can be executed by running:

```shell
bundle exec rspec
```

Tests follow quite the same rules as the documentation: Make sure to either add relevant tests (when introducing new concepts or components) or change existing ones to fit your changes (updating existing concepts and components). Pull requests that add/change concepts & components and do not come with corresponding tests will not be approved.

### Note: Running tests on macOS

Make sure you have installed `chromedriver` on your machine. You can install `chromedriver` via `brew` with

```shell
brew cask install chromedriver
```

You can then run your the testsuite with `bundle exec rspec`.

If you get an error about a version mismatch similar to this one:

`Chrome version must be between X and Y (Driver info: chromedriver=X.Y.Z)`

Make sure you update your chromedriver by executing this command in the project root:

```shell
rails app:webdrivers:chromedriver:update
```

## Release

Webpacker is used for managing all JS assets. In order to deploy a packed JS, we use a "builder" app found in `repo_root/builder`. This builder app uses a symlink in order to reference the actual core found in `builder/vendor`.

You can run webpacker inside this builder app to pack JS assets:

```shell
cd builder

./bin/webpack

#or

./bin/webpack --watch
```

All webpack configuration can be found within the builder folder.

For further webpacker documentation: [webpacker](https://github.com/rails/webpacker)
