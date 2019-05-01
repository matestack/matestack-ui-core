# Core Contribution

## Tests

Tests are defined in /spec folder.

Execute them with:

```shell

bundle exec rspec

```

CircleCI is integrated and gets triggered when new commits get pushed on master branch.

## Release

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
