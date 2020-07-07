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
    if name.include?("/")
      require_app_path "concepts/matestack/ui/core/#{name}/#{name.split("/").last}"
    else
      require_app_path "concepts/matestack/ui/core/#{name}/#{name}"
    end
  end

  require_app_path "helpers/matestack/ui/core/application_helper"
  require_app_path "lib/matestack/ui/core/has_view_context"

  require_app_path "concepts/matestack/ui/core/component/base"
  require_app_path "concepts/matestack/ui/core/component/dynamic"
  require_app_path "concepts/matestack/ui/core/component/rerender"
  require_app_path "concepts/matestack/ui/core/component/static"

  require_core_component "abbr"
  require_core_component "address"
  require_core_component "area"
  require_core_component "article"
  require_core_component "aside"
  require_core_component "async"
  require_core_component "b"
  require_core_component "bdi"
  require_core_component "bdo"
  require_core_component "blockquote"
  require_core_component "br"
  require_core_component "button"
  require_core_component "caption"
  require_core_component "cite"
  require_core_component "code"
  require_core_component "data"
  require_core_component "datalist"
  require_core_component "dd"
  require_core_component "del"
  require_core_component "details"
  require_core_component "dfn"
  require_core_component "dialog"
  require_core_component "div"
  require_core_component "dl"
  require_core_component "dt"
  require_core_component "heading"
  require_core_component "link"
  require_core_component "main"
  require_core_component "nav"
  require_core_component "paragraph"
  require_core_component "plain"
  require_core_component "span"
  require_core_component "summary"
  require_core_component "table"
  require_core_component "tbody"
  require_core_component "td"
  require_core_component "tfoot"
  require_core_component "th"
  require_core_component "thead"
  require_core_component "tr"
  require_core_component "transition"
  require_core_component "form"
  require_core_component "form/input"
  require_core_component "form/select"
  require_core_component "form/submit"
  require_core_component "onclick"
end

Matestack::Ui::Core::Component::Registry.register_components(
  abbr: Matestack::Ui::Core::Abbr::Abbr,
  address: Matestack::Ui::Core::Address::Address,
  area: Matestack::Ui::Core::Area::Area,
  article: Matestack::Ui::Core::Article::Article,
  aside: Matestack::Ui::Core::Aside::Aside,
  async: Matestack::Ui::Core::Async::Async,
  b: Matestack::Ui::Core::B::B,
  bdi: Matestack::Ui::Core::Bdi::Bdi,
  bdo: Matestack::Ui::Core::Bdo::Bdo,
  blockquote: Matestack::Ui::Core::Blockquote::Blockquote,
  br: Matestack::Ui::Core::Br::Br,
  button: Matestack::Ui::Core::Button::Button,
  caption: Matestack::Ui::Core::Caption::Caption,
  cite: Matestack::Ui::Core::Cite::Cite,
  code: Matestack::Ui::Core::Code::Code,
  data: Matestack::Ui::Core::Data::Data,
  datalist: Matestack::Ui::Core::Datalist::Datalist,
  dd: Matestack::Ui::Core::Dd::Dd,
  del: Matestack::Ui::Core::Del::Del,
  details: Matestack::Ui::Core::Details::Details,
  dfn: Matestack::Ui::Core::Dfn::Dfn,
  dialog: Matestack::Ui::Core::Dialog::Dialog,
  div: Matestack::Ui::Core::Div::Div,
  dl: Matestack::Ui::Core::Dl::Dl,
  dt: Matestack::Ui::Core::Dt::Dt,
  heading: Matestack::Ui::Core::Heading::Heading,
  link: Matestack::Ui::Core::Link::Link,
  main: Matestack::Ui::Core::Main::Main,
  nav: Matestack::Ui::Core::Nav::Nav,
  paragraph: Matestack::Ui::Core::Paragraph::Paragraph,
  plain: Matestack::Ui::Core::Plain::Plain,
  span: Matestack::Ui::Core::Span::Span,
  summary: Matestack::Ui::Core::Summary::Summary,
  transition: Matestack::Ui::Core::Transition::Transition,
  table: Matestack::Ui::Core::Table::Table,
  tbody: Matestack::Ui::Core::Tbody::Tbody,
  td: Matestack::Ui::Core::Td::Td,
  tfoot: Matestack::Ui::Core::Tfoot::Tfoot,
  th: Matestack::Ui::Core::Th::Th,
  thead: Matestack::Ui::Core::Thead::Thead,
  tr: Matestack::Ui::Core::Tr::Tr,
  form: Matestack::Ui::Core::Form::Form,
  form_input: Matestack::Ui::Core::Form::Input::Input,
  form_select: Matestack::Ui::Core::Form::Select::Select,
  form_submit: Matestack::Ui::Core::Form::Submit::Submit,
  onclick: Matestack::Ui::Core::Onclick::Onclick,
)
