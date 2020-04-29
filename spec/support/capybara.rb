require 'capybara/rspec'
require 'capybara/rails'
require "selenium/webdriver"

require "matestack/ui/core"

Capybara.server_port = 33123
Capybara.server_host = "0.0.0.0"


Capybara.server_port = 33123
Capybara.server_host = "0.0.0.0"


# Capybara.app = Matestack::Ui::Core::Engine
Capybara.app = Dummy::Application

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu no-sandbox disable-dev-shm-usage --enable-features=NetworkService,NetworkServiceInProcess) },
    loggingPrefs: {browser: 'ALL'}
  )

  # caps = Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs:{browser: 'ALL'})
  # browser_options = ::Selenium::WebDriver::Chrome::Options.new()
  # browser_options.args << '--some_option' # add whatever browser args and other options you need (--headless, etc)

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome

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
