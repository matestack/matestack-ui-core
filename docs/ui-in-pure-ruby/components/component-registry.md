# Component Registry

{% hint style="info" %}
Since version 2.0.0, components do not need to be registered anymore but can be called via an alias method defined in a Ruby module like:
{% endhint %}

By default, components can be called directly like `Components::Card.(title: "foo", body: "bar")` which will return the desired HTML string.

If desired, you can create alias methods in order to avoid the class call syntax:

{% code title="app/matestack/components/registry.rb" %}
```ruby
module Components::Registry

  def card(text=nil, options=nil, &block)
    Components::Card.(text, options, &block)
  end

  #...

end
```
{% endcode %}

which then allows you to call the card component like `card(title: "foo", body: "bar")` if the above shown module is included properly.

As this is just a plain Ruby module, you need to include it in all contexts you want to use the alias method \(unlike the registry prior to 2.0.0\). It's a good idea to create your own ApplicationPage, ApplicationComponent and ApplicationApp as base classes for your pages, components ans apps. In there, you include your component registry module\(s\) only once and have access to the alias methods in all child classes:

{% code title="app/matestack/appplication\_page.rb" %}
```ruby
class ApplicationPage < Matestack::Ui::Page

  include Components::Registry

end
```
{% endcode %}

{% code title="app/matestack/appplication\_component.rb" %}
```ruby
class ApplicationComponent < Matestack::Ui::Component

  include Components::Registry

end
```
{% endcode %}

{% code title="app/matestack/application\_app.rb" %}
```ruby
class ApplicationApp< Matestack::Ui::App

  include Components::Registry

end
```
{% endcode %}

