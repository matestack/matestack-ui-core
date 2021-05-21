# Contribute \[WIP\]

We are very happy about anyone that wants to improve this project! Please make sure to read this guide before starting your work to avoid unnecessary trouble down the road! 

{% hint style="info" %}
Always make sure to reach out to us via [Discord](https://discord.gg/c6tQxFG) or mail \(jonas@matestack.io\) if you want to start developing features or fixing bugs! It's way easier for you to get going if you get some initial support from the Core Team :\)
{% endhint %}

Asking questions, creating GitHub Issues, adjusting things through PRs... every kind of community contribution counts:

## Reporting issues

\[WIP\]

## Propose features

\[WIP\]

## Adding features or fixing bugs

In order to work on the core code to add features or fix reported bugs, you should clone the repo first:

```bash
git clone git@github.com:matestack/matestack-ui-core.git
cd matestack-ui-core
git checkout -b "your_feature/bugfix_branch_name"
```

We dockerized the core development/testing in order to make it as convenient as possible to contribute to `matestack-ui-core`.

You will need to install docker and docker-compose:

* [Install Docker on Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-convenience-script)
* [Install docker-compose](https://docs.docker.com/compose/install/)

### Dummy app

#### Setup the dummy app

In order to migrate the database and install yarn/npm packages, do:

```text
docker-compose build dummy
docker-compose run --rm dummy yarn install
docker-compose run --rm dummy sh -c "cd spec/dummy && npm install"
docker-compose run --rm dummy bundle exec rake db:setup SKIP_TEST_DATABASE=true
```

{% hint style="danger" %}
The JavaScript packages within the dummy folder have to be resolved via NPM unlike the JavaScript packages within the root directory, which are resolved via YARN.
{% endhint %}

If you already created sqlite files locally in `spec/dummy/db`, the command `docker-compose run --rm dummy bundle exec rake db:setup SKIP_TEST_DATABASE=true` will fail. Please remove the locally created sqlite files and rerun the command

{% hint style="info" %}
You might need to redo these steps if new migrations or yarn/npm packages are added/updated. Always remember to resolve JavaScript packages with NPM within the dummy app rather than using YARN.
{% endhint %}

#### Run the dummy app

The dummy app provides a good playground for Matestacks core development in order to review effects of core implementation changes hands on in a browser. The source code can be found and manipulated \(be careful what you commit\) at `spec/dummy`. Run it like seen below:

```text
docker-compose up dummy
```

{% hint style="warning" %}
Be aware that whenever you change any **Ruby** file within the core implementation, you need to restart the dummy app in order to see effects of your changes within the dummy app. Currently the core code, defined in `lib` is not automatically reloaded. We want to fix that soon.

That does not apply for **JavaScript** files as they are compiled via Webpacker automatically without a server restart required.
{% endhint %}

Visit `localhost:3000` in order to visit the dummy app. Feel free to modify it and play around with components and concepts. Just don't push your local changes to the remote repo.

The pages/component used in the dummy app live in `spec/dummy/app/matestack`.

### Run the Webpack watcher

During development, the Webpack watcher can be used to compile the JavaScript when any relevant JavaScript source code is changed. Run it in a separate terminal tab like seen below:

```text
docker-compose up webpack-watcher
```

### Rerun bundle/yarn install in a Docker container

In order to execute commands such as `bundle install`, `yarn install` or `npm install` you need to run:

```text
docker-compose run --rm dummy bundle install
docker-compose run --rm dummy yarn install
docker-compose run --rm dummy sh -c "cd spec/dummy && npm install"
```

### Optional: run commands as your user in a Docker container

When running commands, which generates files \(e.g. rails generator usage\), which then are mounted to your host filesystem, you need to tell the Docker container that it should run with your user ID.

```text
CURRENT_UID=$(id -u):$(id -g) docker-compose run --rm dummy bash

# and then your desired command such as:

rails generate ...
```

Otherwise the generated files will be owned by the `root` user and are only writeable when applying `sudo`.

**Note:** `bundle install` and `yarn install` can't be executed inside the Docker container as the current user. `CURRENT_UID=$(id -u):$(id -g) docker-compose run --rm dummy bundle install` will not work.

### Testing

To assure this project is and remains in great condition, we heavily rely on automated tests. Tests are defined in `/spec` folder

#### Setup the test ENV

```text
docker-compose build test
docker-compose run --rm test yarn install
docker-compose run --rm test sh -c "cd spec/dummy && npm install"
docker-compose run --rm test bundle exec rake db:setup
```

{% hint style="danger" %}
The JavaScript packages within the dummy folder have to be resolved via NPM unlike the JavaScript packages within the root directory, which are resolved via YARN.
{% endhint %}

{% hint style="info" %}
You might need to redo these steps if new migrations or yarn/npm packages are added/updated. Always remember to resolve JavaScript packages with NPM within the dummy app rather than using YARN.
{% endhint %}

#### Run the specs

```bash
docker-compose run --rm --service-ports test bash

# and then inside the container:

cd spec/dummy
./bin/webpack # always make sure to have the latest JS assets compiled

cd ../..

bundle exec rspec spec/test # run all tests
bundle exec rspec spec/test/components/xyz.rb(:123) # run a specific test (:line_number)
```

{% hint style="info" %}
Always make sure to compile the JavaScript assets via `./bin/webpack` in the `spec/dummy` folder before running the specs. You can also run `./bin/webpack --watch` in a separate test container \(without `--service-ports`\). The compiled assets are mounted to your filesystem.
{% endhint %}

## Documentation & test coverage

Documentation can be found in the `/docs/*` folder. Please make sure to cover basic use cases of your concepts & components for other users! Feel free to take a look at other examples and copy their structure!

Note: We will not approve pull requests that introduce new concepts or components without documentation. Same goes for existing concepts & components. If you change the behavior of an existing part of this project, make sure to also update the corresponding part of the documentation!

Tests follow quite the same rules as the documentation: Make sure to either add relevant tests \(when introducing new concepts or components\) or change existing ones to fit your changes \(updating existing concepts and components\). Pull requests that add/change concepts & components and do not come with corresponding tests will not be approved.

