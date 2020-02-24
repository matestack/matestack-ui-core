# Responsible for registering all the components under their names.
# TODO: Better file name?

# TODO: app folder isn't in the LOAD_PATH 🤔
# --> because of rails autoload when running as an engine, maybe add
# app to loadpath? But we might move away from app in favor of lib anyhow.

module Matestack::Ui::Core::Components
  def self.require_app_path(path)
    require_relative "../../../../app/#{path}"
  end

  def self.require_core_component(name)
    require_app_path "concepts/matestack/ui/core/#{name}/#{name}"
  end

  require_app_path "helpers/matestack/ui/core/application_helper"
  require_app_path "lib/matestack/ui/core/has_view_context"

  require_app_path "concepts/matestack/ui/core/component/base"
  require_app_path "concepts/matestack/ui/core/component/dynamic"
  require_app_path "concepts/matestack/ui/core/component/static"

  require_core_component "br"
  require_core_component "button"
  require_core_component "div"
  require_core_component "heading"
  require_core_component "link"
  require_core_component "main"
  require_core_component "nav"
  require_core_component "plain"
  require_core_component "span"
  require_core_component "transition"
end



Matestack::Ui::Core::Component::Registry.register_components(
  button: Matestack::Ui::Core::Button::Button,
  br: Matestack::Ui::Core::Br::Br,
  div: Matestack::Ui::Core::Div::Div,
  heading: Matestack::Ui::Core::Heading::Heading,
  link: Matestack::Ui::Core::Link::Link,
  main: Matestack::Ui::Core::Main::Main,
  nav: Matestack::Ui::Core::Nav::Nav,
  plain: Matestack::Ui::Core::Plain::Plain,
  span: Matestack::Ui::Core::Span::Span,
  transition: Matestack::Ui::Core::Transition::Transition,
)
