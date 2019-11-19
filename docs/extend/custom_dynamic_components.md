# Custom dynamic components

To create dynamic behavior, you got either:

- use a bunch of `dynamic core components` (like async, emit ...) inside a `custom static component` ([examp below](#dynamic-core-components-inside-a-custom-static_component))
- wrap a `custom static component` in a `dynamic core component` ([example below](#async-wrapper-around-static-components))
- create a custom dynamic component with a corresponding Vue.js counterpart ([example below](#dynamic-components-with-custom-))


## Dynamic core components inside a custom static component

Create a `custom static component` in `app/matestack/components/some/component.rb`

```ruby
class Components::Some::Component < Matestack::Ui::StaticComponent

  def response
    components {
      div id: "my-component" do
        async rerender_on: "my_event" do
          plain DateTime.now.strftime('%Q')
        end
      end
    }
  end

end
```

and add it to the Example Page.

Since we've put a `dynamic core component` inside our `custom static component`, the timestamp inside our custom component gets updated whenever *\"my_event\"* happens - for example by an `onclick` component, as shown below:

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        custom_some_component

        onclick emit "my_event"
      end
    }
  end

end
```

## Async wrapper around static components

Create a `custom static component` in `app/matestack/components/some/component.rb`

```ruby
class Components::Some::Component < Matestack::Ui::StaticComponent

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
        plain DateTime.now.strftime('%Q')
      end
    }
  end

end
```

and add it to the Example Page, wrapping it into an *async component* to make it *dynamic*! The *async component* is a `core component` and therefore does not need the *custom_* prefix.

Now, the page will respond with static content, but our component rerenders (visible by looking at the timestamp) whenever *\"my_event\"* happens. This event may be triggered by all kinds of other components, for example an `onclick` component, as shown below:

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        onclick emit "my_event"

        async rerender_on: "my_event" do
          custom_some_component
        end
      end
    }
  end

end
```

## Dynamic components with custom Vue.js

To create a custom dynamic component (we will call our example one *FancyComponent*), create an associated file such as `app/matestack/components/fancy/component.rb`.

While `custom static components` inherit from `Matestack::Ui::StaticComponent`, `custom dynamic component` inherit from *a different class*, namely `Matestack::Ui::DynamicComponent`:

```ruby
class Components::Fancy::Component < Matestack::Ui::DynamicComponent

  def response
    components {
      div id: "my-component" do
        plain "I'm a fancy dynamic component! Call me {{dynamic_value}}!"
      end
    }
  end

end
```

The JavaScript part is defined in `app/matestack/components/fancy/component.js` as a Vue.js component:

```javascript
MatestackUiCore.Vue.component('custom-fancy-component', {
  mixins: [MatestackUiCore.componentMixin],
  data: function data() {
    return {
      dynamic_value: "foo"
    };
  },
  mounted(){
    const self = this
    setTimeout(function () {
      self.dynamic_value = "bar"
    }, 300);
  }
});
```

**Important:** You need to add this `component.js` to your `application.js`, below the `matestack-ui-core`:

`app/assets/javascripts/application.js`

```javascript
//[...]
//= require matestack-ui-core
//[...]
//= require fancy/component
//[...]
```

And, if it has not already been done, you also need to modify `config/initializers/assets.rb`:

```ruby
Rails.application.config.assets.paths << Rails.root.join('app/matestack/components')
```

Add the dynamic component to an example page the same way it is done with static components:

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        custom_fancy_component
      end
    }
  end

end
```

On initial pageload, this is the HTML received:

```html
<div id="div-on-page">
  <div id="my-component">
    I'm a fancy dynamic component! Call me foo!
  </div>
</div>
```

And after 300ms, *foo* changes into *bar* dynamically - nice!
