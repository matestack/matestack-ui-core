# Registry

By default, components can be called directly like `Components::Card.call(title: "foo", body: "bar")` which will return the desired HTML string.

If desired, you can create alias methods in order to avoid the class call syntax:

{% code title="app/matestack/components/registry.rb" %}
```ruby
module Components::Registry

  def card(text=nil, options=nil, &block)
    Components::Card.call(text, options, &block)
  end

  #...

end
```
{% endcode %}

which then allows you to call the card component like `card(title: "foo", body: "bar")` if the above shown module is included properly.

As this is just a plain Ruby module, you need to include it in all contexts you want to use the alias method. It might be a good idea to create your own `ApplicationPage`, `ApplicationComponent` and `ApplicationLayout` as base classes for your pages, components ans layouts. In there, you include your component registry module(s) only once and have access to the alias methods in all child classes:

{% code title="app/matestack/application_page.rb" %}
```ruby
class ApplicationPage < Matestack::Ui::Page

  include Components::Registry

end
```
{% endcode %}

{% code title="app/matestack/application_component.rb" %}
```ruby
class ApplicationComponent < Matestack::Ui::Component

  include Components::Registry

end
```
{% endcode %}

{% code title="app/matestack/application_layout.rb" %}
```ruby
class ApplicationLayout < Matestack::Ui::Layout

  include Components::Registry

end
```
{% endcode %}
