require 'capybara/rspec'
require 'capybara/rails'
require "selenium/webdriver"

require "matestack/ui/core"

Capybara.server_port = 33123
Capybara.server_host = "0.0.0.0"

Capybara.app = Dummy::Application

Capybara.register_driver :selenium do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new.tap do |o|
    o.add_argument '--headless'
    o.add_argument '--no-sandbox'
    o.add_argument '--disable-dev-shm-usage'
    o.add_argument '--disable-gpu'
    o.add_argument '--enable-features=NetworkService,NetworkServiceInProcess'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
end
Capybara.default_driver = :selenium