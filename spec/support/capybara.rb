require 'capybara/rspec'
require 'capybara/rails'
require "basemate/ui/core"

Capybara.app = Basemate::Ui::Core::Engine

RSpec.configure do |config|
  # config.include RecruiticsAuth::Engine.routes.url_helpers
end
