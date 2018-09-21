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
  s.summary     = "Summary of Basemate::Ui::Core."
  s.description = "Description of Basemate::Ui::Core."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0"
  s.add_dependency "trailblazer"
  s.add_dependency "trailblazer-rails"
  s.add_dependency "trailblazer-cells"
  s.add_dependency "cells-rails"
  s.add_dependency "cells-haml"
end
