require 'capybara/rspec'
require 'capybara/rails'
# require 'capybara/poltergeist'
require "selenium/webdriver"

require "matestack/ui/core"


# Capybara.javascript_driver = :poltergeist

# Capybara.app = Matestack::Ui::Core::Engine
Capybara.app = Dummy::Application

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu no-sandbox disable-dev-shm-usage) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.javascript_driver = :chrome

# Capybara.server = :webrick
#
# Capybara.register_driver :selenium do |app|
#   Capybara::Selenium::Driver.new(app, browser: :selenium_chrome)
# end
#
# Capybara.javascript_driver = :selenium_chrome
#
# Capybara.configure do |config|
#   config.default_max_wait_time = 3 # seconds
#   config.default_driver        = :selenium
# end

RSpec.configure do |config|
  # config.include RecruiticsAuth::Engine.routes.url_helpers
end
