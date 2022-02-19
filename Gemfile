source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in matestack-ui-core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'rails', '7.0.1'

group :development, :test do
  gem 'rspec-rails', '~> 4.0.2'
  gem 'capybara'
  gem 'webpacker', '~> 5.0'
  gem 'pg', '>= 0.18', '< 2.0'
  gem 'selenium-webdriver'
  gem 'puma'
  gem 'simplecov', require: false, group: :test
  gem 'byebug'
  gem 'webmock'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  gem "generator_spec"
  # gem "rspec-retry" # repeating flaky tests
  # gem "rspec-wait", "~> 0.0.9"
end
