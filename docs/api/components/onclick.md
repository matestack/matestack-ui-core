# matestack core component: Onclick

Show [specs](../../spec/usage/components/onclick_spec.rb)

The `onclick` component renders a div that runs a function when the user clicks on it. This is a simple component that can be used to wrap components with a onclick function that will emit a event. The event that must be emitted onclick can defined by passing a hash into the `onclick` component that has the key `emit`. See example below for more details.

```ruby
class Pages::MyPage::Home < Matestack::Ui::Page
  def response
    components{
      onclick(emit: "abc") do
        plain "Hello world"
      end
    }
    async rerender_on: "abc" do
      plain "Render this text when the 'abc' event is emitted"
    end
  end
end
```
