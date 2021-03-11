# Async

The `async` component enables us to rerender parts of the UI based on events without full page reload.

Please be aware that, if not configured otherwise, the `async` core component does get loaded and displayed on initial pageload!

## Parameters

The async core component accepts the following parameters:

### ID \(required\)

The `async` component needs an ID in order to resolve the correct content on an async HTTP request

```ruby
async id: "some-unique-id" do
  #...
end
```

### Rerender\_on \(optional\)

The `rerender_on` option lets us define an event on which the component gets rerendered.

```ruby
async rerender_on: 'my_event', id: "some-unique-id" do
  div id: 'my-div' do
    plain "#{DateTime.now.strftime('%Q')}"
  end
end
```

**Note:** The `rerender_on` option lets you rerender parts of your UI asynchronously. But please consider that, if not configured differently, it

a\) is **not** _lazily loaded_ and

b\) and does get displayed on initial pageload

by default.

Lazy \(or defered\) loading can be configured like shown [here](async.md#defer).

You can pass in multiple, comma-separated events on which the component should rerender.

```ruby
async rerender_on: 'my_event, some_other_event', id: "some-unique-id"
```

### Defer

The `defer` option may be used in two ways:

#### simple defer

`defer: true` implies that the content of the `async` component gets requested within a separate GET request right after initial page load is done.

```ruby
async defer: true, id: "some-unique-id"do
  div id: 'my-div' do
    plain 'I will be requested within a separate GET request right after initial page load is done'
  end
end
```

#### delayed defer

`defer: 2000` means that the content of the `async` component gets requested within a separate GET request 2000 milliseconds after initial page load is done.

```ruby
async defer: 2000, id: "some-unique-id" do
  div id: 'my-div' do
    plain 'I will be requested within a separate GET request 2000ms after initial page load is done'
  end
end
```

The content of an `async` component with activated `defer` behavior is not resolved within the first page load!

```ruby
#...
async defer: 1000, id: "some-unique-id" do
  some_database_data = SomeModel.some_heavy_query
  div id: 'my-div' do
    some_database_data.each do |some_instance|
      plain some_instance.id
    end
  end
end
async defer: 2000, id: "some-unique-id" do
  some_other_database_data = SomeModel.some_other_heavy_query
  div id: 'my-div' do
    some_other_database_data.each do |some_instance|
      plain some_instance.id
    end
  end
end
#...
```

The `SomeModel.some_query` does not get executed within the first page load and only will be called within the deferred GET request. This helps us to render a complex UI with loads of heavy method calls step by step without slowing down the initial page load and rendering of simple content.

## DOM structure, loading state and animations

Async components will be wrapped by a DOM structure like this:

```markup
<div class="matestack-async-component-container">
  <div class="matestack-async-component-wrapper">
    <div class="matestack-async-component-root" >
      hello!
    </div>
  </div>
</div>
```

During async rendering a `loading` class will automatically be applied, which can be used for CSS styling and animations:

```markup
<div class="matestack-async-component-container loading">
  <div class="matestack-async-component-wrapper loading">
    <div class="matestack-async-component-root" >
      hello!
    </div>
  </div>
</div>
```

## Examples

See some common use cases below:

### Example 1 - Rerender on event

On our example page, we wrap a simple timestamp in an async component and tell it to rerender when the event `my_event` gets triggered.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    async rerender_on: 'my_event', id: "some-unique-id" do
      div id: 'my-div' do
        plain "#{DateTime.now.strftime('%Q')}"
      end
    end
  end

end
```

Not surprisingly, the timestamp gets updated after our event was fired!

### Example 2: Deferred loading

On our example page, we wrap our async event around a placeholder for the event message.

\`\`\`ruby class ExamplePage &lt; Matestack::Ui::Page

def response async defer: true, id: "some-unique-id" do div id: 'my-div' do plain 'I will be requested within a separate GET request right after initial page load is done' end end end

end

