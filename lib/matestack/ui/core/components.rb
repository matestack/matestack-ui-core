# Responsible for registering all the components under their names.
# TODO: Better file name?

# TODO: app folder isn't in the LOAD_PATH 🤔

# Not sustainable this is, hrrrm?
require_relative "../../../../app/lib/matestack/ui/core/render"
require_relative "../../../../app/helpers/matestack/ui/core/application_helper"
require_relative "../../../../app/lib/matestack/ui/core/has_view_context"

require_relative "../../../../app/concepts/matestack/ui/core/component/base"
require_relative "../../../../app/concepts/matestack/ui/core/component/dynamic"
require_relative "../../../../app/concepts/matestack/ui/core/component/static"

require_relative "../../../../app/concepts/matestack/ui/core/button/button"
require_relative "../../../../app/concepts/matestack/ui/core/plain/plain"

Matestack::Ui::Core::Component::Registry.register_components(
  button: Matestack::Ui::Core::Button::Button,
  plain: Matestack::Ui::Core::Plain::Plain,
)
