# matestack core component: Action

Show [specs](../../spec/usage/components/onclick_spec.rb)

The `onclick` component renders a div that runs a function on click. This is a nice component for use cases where you would like to wrap multiple components into one click function. The function called by the onclick component requires two fields. These two fields are `emit` and `data`. These two fields are then emitted as a event in javascript when the component is clicked

```ruby
class Pages::MyPage::Home < Matestack::Ui::Page
  def response
    components{
      onclick run_this_function do
        plain "Hello world"
      end
    }
  end

  def run_this_function
    return {
      emit: "abc",
      data: {
        id: 1,
        name: "John",
        detail: "Clicked the button"
      }
    }
  end
end
```
