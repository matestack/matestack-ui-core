require 'capybara/rspec'
require 'capybara/rails'
require "basemate/ui/core"

# Capybara.app = Basemate::Ui::Core::Engine
Capybara.app = Dummy::Application

RSpec.configure do |config|
  # config.include RecruiticsAuth::Engine.routes.url_helpers
end
