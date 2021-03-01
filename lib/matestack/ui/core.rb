base_path = 'matestack/ui/core'
require "#{base_path}/version"

module Matestack
  module Ui
    module Core
      
    end
  end
end

require "#{base_path}/context"
require "#{base_path}/properties"
require "#{base_path}/base"
require "#{base_path}/component_registry"
require "#{base_path}/component"
require "#{base_path}/page"
require "#{base_path}/app"
require "#{base_path}/helper"

# require abbreveations for apps, pages and components
require "matestack/ui/app"
require "matestack/ui/page"
require "matestack/ui/component"

# require 'trailblazer/cell'
# require 'cell/rails'
# require 'cell/haml'

# require "matestack/ui/core/cell"
# require "matestack/ui/core/engine"

# require "matestack/ui/core/dsl"
# require "matestack/ui/core/component/registry"
# require "matestack/ui/core/components"

# module Matestack
#   module Ui
#     module Core
#       # Your code goes here...
#     end
#   end
# end
