# Custom actionview components

Show [specs](/spec/usage/extend/custom_component_spec.rb).

Custom `actionview components`, both `static` and `dynamic`, are a way to harness the power of various Rails `ActionView` helpers without including them in your `custom components`.

## Static actionview components

This is just a simple exmaple of a `custom static actionview component`. Notice that it inherits from a different class than [generic custom static components](/docs/extend/custom_static_components.md).

Create a `custom static actionview component` in `app/matestack/components/time_ago.rb`

```ruby
class Components::TimeAgo < Matestack::Ui::StaticActionviewComponent

  def prepare
    @from_time = Time.now - 3.days - 14.minutes - 25.seconds
  end

  def response
    components {
      div id: 'my-component-1' do
        plain time_ago_in_words(@from_time)
      end
    }
  end

end
```

We can add it our `ExamplePage` the way we would add a generic `custom static component`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: 'div-on-page' do
        custom_timeAgo
      end
    }
  end

end
```

and receive the following output:

```HTML
<div id="div-on-page">
  3 days
</div>
```

## Dynamic actionview components

This is just a simple exmaple of a `custom dynamic actionview component`. Notice that it inherits from a different class than [generic custom dynamic components](/docs/extend/custom_dynamic_components.md).

Create a `custom dynamic actionview component` in `app/matestack/components/time_click.rb`

```ruby
class Components::TimeClick < Matestack::Ui::DynamicActionviewComponent

  def prepare
    @start_time = Time.now
  end

  def response
    components {
      div id: 'my-component-1' do
        plain "{{dynamic_value}} #{distance_of_time_in_words(@start_time, Time.now, include_seconds: true)}"
      end
    }
  end

end
```

and the corresponding Vue.js component in `app/matestack/components/time_click.js`

```javascript
MatestackUiCore.Vue.component('custom-timeclick', {
  mixins: [MatestackUiCore.componentMixin],
  data: function data() {
    return {
      dynamic_value: "Now I show: "
    };
  },
  mounted(){
    const self = this
    setTimeout(function () {
      self.dynamic_value = "Later I show: "
    }, 300);
  }
});
```

We can now add it our `ExamplePage` the way we would add a generic `custom dynamic component`


```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: 'div-on-page' do
        custom_timeClick
      end
    }
  end

end
```

Initially, the page will display `Now I show: less than 5 seconds`, but after 300ms, it gets changed into `Later I show: less than 5 seconds`. Nice!
