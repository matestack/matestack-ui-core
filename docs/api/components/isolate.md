# matestack core component: Isolate

Show [specs](/spec/usage/components/isolate_spec.rb)

The `isolate` component allows you to create isolated "scopes", which can be rendered without calling the main response method of a `page`. Used with `async`, only specific isolated scopes are resolved on the serverside rather than resolving the whole UI when asynchronously rerendering parts of the UI. Usage seems to be similar to `partial`, but there are important differences! Read below!

**the isolate/async components currently only work on page-level --> we're working on it in order support the usage of async/isolate within a component [#75](https://github.com/matestack/matestack-ui-core/issues/75)**

## Parameters

The isolate core component accepts the following parameters:

### isolated method (as a symbol) (mandatory)

Just like a partial, using a symbol, a specific part of the UI can be referenced:

```ruby
def response
  components{
    #a lot of other UI components you want to bypass if you rerender the isolated scope

    isolate :my_isolated_scope

    #a lot of other UI components you want to bypass if you rerender the isolated scope

    #for emphasizing the difference, a similar partial would work like so:
    partial :my_partial_scope
  }
end

def my_isolated_scope
  @some_data = SomeModel.find(42)

  isolate{
    async rerender_on: "some_event" do
      div do
        plain @some_data.some_attribute
      end
    end
  }
end

def my_partial_scope
  @some_data = SomeModel.find(42)

  partial{
    async rerender_on: "some_other_event" do
      div do
        plain @some_data.some_attribute
      end
    end
  }
end
```

As mentioned in the example code above: The `async` requests a new version of `my_isolated_scope` after the event `some_event` is received. But instead of resolving the whole UI and then returning only the desired part, the `isolate` component takes care of bypassing all irrelevant parts of the UI. The `async` rerender action inside the `partial` in contrast would call the whole `response` method of the page, which can lead to significant higher response times.


### Cached Params (Clientside params --> public!)

As the isolated scope is truly encapsulated from the main `response` method while rerendering, simply passing in dynamic params from within the `response` method can not work. As it is often necessary, to render "partials" dynamically, we can use `cached_params` for isolated scopes. These params are stored on the clientside after initial page and then used when performing the rerender action. Using this approach, we can still bypass the main `response` method while using dynamic params.

**Just put simple data into cached_params (simple integers or strings, no hashes etc). Never put sensible data into cached_params as they are visible on the clientside!**

```ruby
def response
  components{
    #a lot of other UI components you want to bypass if you rerender the isolated scope

    [1, 2, 3].each do |id|
      isolate :my_isolated_scope, cached_params: { id: id }
    end

    #a lot of other UI components you want to bypass if you rerender the isolated scope

    #for emphasizing the difference, a similar partial would work like so:
    [1, 2, 3].each do |id|
      partial :my_partial_scope, id
    end
  }
end

def my_isolated_scope cached_params
  @some_data = SomeModel.find(cached_params[:id])

  isolate{
    async rerender_on: "isolated_rerender_#{cached_params[:id]}" do
      div do
        plain @some_data.some_attribute
      end
    end
  }
end

def my_partial_scope id
  @some_data = SomeModel.find(id)

  partial{
    async rerender_on: "partial_rerender_#{id}" do
      div do
        plain @some_data.some_attribute
      end
    end
  }
end
```
