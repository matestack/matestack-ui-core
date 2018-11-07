[![CircleCI](https://circleci.com/gh/basemate/basemate-ui-core/tree/master.svg?style=shield)](https://circleci.com/gh/basemate/basemate-ui-core/tree/master)

# Basemate UI Core

## What is basemate?

basemate is a "Rails Engine", turning the MVC-Framework "Ruby on Rails" into a
Fullstack Web-Development Framework. With basemate you are able to write dynamic
Web-Apps in pure Ruby. Javascript/HTML/CSS is only used for adding special, custom
UI-Behaviour.

basemate is designed to write maintainable, dynamic Web-UIs on top of Rails and Vue.js with
minimum effort. In order to increase development speed, basemate's architecture
moves back- and frontend development closer together. In other words: basemate
melts Rails and Vue.js down to one holistic Web App Development Framework.

basemate progressively replaces the classic Rails-View-Layer. You are able to use
it alongside your classic views and incrementally turn your Rails-App into a
dynamic, more maintainable Web-App.


## Current State
This repo is currently under heavy development and should not be used until the
first tested, stable version is released. Please use it only after being
onboarded by the basemate team. Feel free to reach out if you really can't
wait to start :)

## Documentation

Documentation is built with basemate and hosted here: [Docs](https://basemate-ui-core.herokuapp.com)

Source code of documentation can be found here: [Docs Source](https://github.com/basemate/basemate-ui-core-docs)

## Core Contribution

### Tests

Tests are defined in /spec folder.

Execute them with:

```shell

bundle exec rspec spec/concepts

```

CircleCI is integrated and gets triggered when new commits get pushed on master branch.

### Release

Webpacker is used for managing all JS assets. In order to deploy a packed JS, we
use a "builder" app found in repo_root/builder
This builder app uses a symlink in order to reference the actual core found in
builder/vendor.

You can run webpacker inside this builder app in order to pack JS assets:

```shell
cd builder

./bin/webpack

#or

./bin/webpack --watch
```

All webpack configuration can be found within the builder folder.

For further webpacker documentation: [webpacker](https://github.com/rails/webpacker)

## License
The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
