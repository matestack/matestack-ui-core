# Responsible for registering all the components under their names.
# TODO: Better file name?

# TODO: app folder isn't in the LOAD_PATH 🤔

module Matestack::Ui::Core::Components
  def self.require_app_path(path)
    require_relative "../../../../app/#{path}"
  end

  def self.require_core_component(name)
    require_app_path "concepts/matestack/ui/core/#{name}/#{name}"
  end

  require_app_path "lib/matestack/ui/core/render"
  require_app_path "helpers/matestack/ui/core/application_helper"
  require_app_path "lib/matestack/ui/core/has_view_context"

  require_app_path "concepts/matestack/ui/core/component/base"
  require_app_path "concepts/matestack/ui/core/component/dynamic"
  require_app_path "concepts/matestack/ui/core/component/static"

  require_core_component "button"
  require_core_component "div"
  require_core_component "plain"
  require_core_component "span"
end



Matestack::Ui::Core::Component::Registry.register_components(
  button: Matestack::Ui::Core::Button::Button,
  plain: Matestack::Ui::Core::Plain::Plain,
  div: Matestack::Ui::Core::Div::Div,
  span: Matestack::Ui::Core::Span::Span,
)
