# Async

Use the `async` component to load or reload content asynchronously depending on events or page initialization. An `async` component can be used to either defer some content on page loads or to rerender a component. For example deferring complex components to increase the initial page load time and render this components asynchronously afterwards. Or rerendering a table after a "reload" button click or rerendering a chat view through action cable events. 

The `async` component can be used to load or reload content asynchronously depending on page initialization or events. Simply wrap your content which you want to render asynchronously inside the `async` component. In order to load the content asynchronously after the initial page load use `defer: true` or pass in a number to delay the defer. To reload content you can use `:rerender_on` with an event name, leveraging the event hub, to reload the content if the specified event occurs. For example rerendering a list of todos beneath the form to create todos to instantly show new created objects. Remember events can also be used with action cable, which you could use for "real time" synchronization.

## Usage

The `async` component is very straightforward in its usage. Every `async` component needs an `:id`, which is necessary for resolving the `async` component and rendering the content in the correct place afterwards. So make sure your ids for async components on the same page are unique. Specifying one of `:defer` or `:rerender_on` or both enables deferred loading and/or rerendering on events. If `:defer` is not configured or false the `async` component will be rendered on page load.

### Deferring content

You can either configure an `async` component to request its content directly after the page load or to delay the request for a given amount of time after the page load. `:defer` expects either a boolean or a integer representing the delay time in milliseconds. If `:defer` is set to `false` the `async` component will be rendered on page load and not deferred. If set to `true` it will request its content directly after the page load.

```ruby
def response
  async id: 'deferred-async', defer: true do
    plain 'Some content rendered after page is loaded.'
  end
end
```

The above `async` component will be rendered asynchronously after page load.

```ruby
def response
  async id: 'delayed-deferred-async', defer: 500 do
    plain 'Some delayed deferred content'
  end
end
```

Specifying `defer: 500` will delay the asynchronous request after page load of the `async` component for 300ms and render the content afterwards.

### Rerendering content

The `async` leverages the event hub and can react to emitted events. If it receives one or more of the with `:rerender_on` specified events it will asynchronously request a rerender of its content. The response will only include the rerendered html of the `async` component which then replaces the current content of the `async`. If you specify multiple events in `:rerender_on` they need to be seperated by a comma.

```ruby
def response
  async id: 'rerendering-async', rerender_on: 'update-time' do
    paragraph text: Time.now
  end
  onclick emit: 'update-time' do
    button text: 'Update time'
  end
end
```

The above snippet renders a paragraph with the current time and a button "Update time" on page load. If the button is clicked a _update-time_ event is emitted. The `async` component wrapping the paragraph receives the event and reacts to it by requesting its rerendered content from the server and replacing its content with the received html. In this case it will rerender after button click and show the updated time.

### Loading animations

An `async` components wraps its content in a special html structure allowing you to create animations while the components gets loaded or rerendered. It appends a loading class to the wrapping elements while the component is loading or rerendering. To learn more about how to animate loading `async` components checkout its [api documentation](/docs/api/100-components/async.md).


## Complete documentation

If you want to know all details about the `async` component checkout it's [api documentation](/docs/api/100-components/async.md)





![Coming Soon](../../images/coming_soon.png)