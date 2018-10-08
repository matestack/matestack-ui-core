$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "basemate/ui/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "basemate-ui-core"
  s.version     = Basemate::Ui::Core::VERSION
  s.authors     = ["Jonas Jabari", "Pascal Wengerter"]
  s.email       = ["jonas@basemate.io", "pascal@basemate.io"]
  s.homepage    = "https://basemate.io"
  s.summary     = "Escape the frontend hustle. Create beautiful software easily. Use basemate."
  s.description = "We're replacing the original view-layer of Ruby on Rails, the most productive MVC framework we know, with our technology. By introducing basemate we get dynamic, fast and simple user interfaces without the need to touch HTML/HAML/ERB/JS/CSS. Plus, it feels like a single page application, but there's no need for all the API hustle SPAs usually bring with them."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0"
  s.add_dependency "trailblazer"
  s.add_dependency "trailblazer-rails"
  s.add_dependency "trailblazer-cells"
  s.add_dependency "cells-rails"
  s.add_dependency "cells-haml"
end
