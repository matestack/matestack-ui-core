$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "matestack/ui/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "matestack-ui-core"
  s.version     = Matestack::Ui::Core::VERSION
  s.authors     = ["Jonas Jabari", "Nils Henning"]
  s.email       = ["jonas@matestack.io", "nils@matestack.io"]
  s.homepage    = "https://matestack.io"
  s.summary     = "Escape the frontend hustle & easily create interactive web apps in pure Ruby."
  s.description = "Matestack provides a collection of open source gems made for Ruby on Rails developers. Matestack enables you to craft interactive web UIs without JavaScript in pure Ruby with minimum effort. UI code becomes a native and fun part of your Rails app."
  s.license     = "LGPLv3"
  s.metadata    = { "source_code_uri" => "https://github.com/matestack/matestack-ui-core" }

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", '>= 5.0'
  s.add_dependency "haml"
  s.add_dependency "trailblazer-cells"
  s.add_dependency "cells-rails"
  s.add_dependency "cells-haml"
end
