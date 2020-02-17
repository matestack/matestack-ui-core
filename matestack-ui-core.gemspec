$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "matestack/ui/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "matestack-ui-core"
  s.version     = Matestack::Ui::Core::VERSION
  s.authors     = ["Jonas Jabari", "Pascal Wengerter"]
  s.email       = ["jonas@matestack.io", "pascal@matestack.io"]
  s.homepage    = "https://matestack.io"
  s.summary     = "Escape the frontend hustle. Create beautiful software easily. Use matestack."
  s.description = "We're replacing the original view-layer of Ruby on Rails, the most productive MVC framework we know, with our technology. By introducing matestack we get dynamic, fast and simple user interfaces without the need to touch HTML/HAML/ERB/JS/CSS. Plus, it feels like a single page application, but there's no need for all the API hustle SPAs usually bring with them."
  s.license     = "MIT"
  s.metadata    = { "source_code_uri" => "https://github.com/matestack/matestack-ui-core" }

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", '~> 5.0'
  s.add_dependency "haml"
  s.add_dependency "trailblazer"
  s.add_dependency "trailblazer-rails", "1.0.9"
  s.add_dependency "trailblazer-cells"
  s.add_dependency "cells-rails"
  s.add_dependency "cells-haml"
  s.add_dependency "docile", "~> 1.3"
end
