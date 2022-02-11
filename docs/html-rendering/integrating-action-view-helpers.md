# Integrating Action View Helpers

Using Rails view helpers ([https://api.rubyonrails.org/classes/ActionView/Helpers.html](https://api.rubyonrails.org/classes/ActionView/Helpers.html)) in components, pages and layouts is supported when using the approaches shown below;

## Helpers without a block

Simple Action View helpers working without a block, can easily be integrated in a Matestack class response by calling `plain`:

```ruby
def response
  plain t("my.locale")
  # ...
  plain link_to "Show", post_path(@post)
  # ...
  plain my_own_view_helper_method
  # ...
  plain any_method_returning_a_string
end
```

## Helpers yielding a block

If you want to use a helper like `form_for` you have to follow following approach:

```ruby
def response
  # ...
  plain do # <-- add this
    form_with url: "/some_path" do |f|
      matestack_to_s do # <-- add this, which converst following block to a string
        plain f.text_field :foo # <-- call plain here again
        br
        div class: "some-input-wrapper" do
          plain f.text_field :bar
        end
        br
        plain f.submit
      end
    end
  end
  # ...
  plain do
    link_to root_path do
      matestack_to_s do
        div class: "some-link-wrapper" do
          plain "foo from block"
        end
      end
    end
  end
  # ...
  # Code below will not work!
  plain link_to root_path do
    matestack_to_s do
      div class: "some-link-wrapper" do
        plain "foo from block"
      end
    end
  end
end
```

{% hint style="info" %}
A component needs to be called in context of a controller (with included `Matestack::Ui::Core::Helper`), which is true when you're calling components from Rails views or on Matestack Pages/Layouts (which are themselves called by a controller normally).

When calling a component in isolation (which is possible), the view helpers might not work properly, especially when (implicitly) requiring a request object!
{% endhint %}

{% hint style="info" %}
We're currently working on an improved way to integrate ActionView Helpers which will enable removing the `plain` calls from your code.
{% endhint %}
