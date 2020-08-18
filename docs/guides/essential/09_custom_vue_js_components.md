# Essential Guide 9: Custom vue.js components

Welcome to the ninth part of our essential guide about building a web application with matestack.

## Introduction

In a [previous guide](/docs/guides/essential/07_partials_and_custom_components.md), we introduced custom components. In this one, we're bringing it to the next level with custom vue.js components!

In this guide, we will
- add a custom vue.js component that fetches and displays data from a 3rd-party API

## Prerequisites

We expect you to have successfully finished the [previous guide](guides/essential/06_static_components.md).

## Hiding content on button click

Remember the `disclaimer` custom component from the last part? Let's turn it into a custom dynamic component. For a dynamic component, we need a JavaScript file.

Since we only used the `app/matestack/components/person/disclaimer.haml` file as a showcase, go ahead and replace it with a file called `disclaimer.js` that contains our JavaScript logic:

```javascript
MatestackUiCore.Vue.component('custom-person-disclaimer', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {
      show: true
    };
  }
});
```

Our component only gets one boolean data variable which is initialized as `true`. Let's put it to use by replacing the contents of `app/matestack/components/person/disclaimer.rb` with the following:

```ruby
class Components::Person::Disclaimer < Matestack::Ui::DynamicComponent

  def response
    div attributes: {"v-show": "show == true"} do
      paragraph text: 'None of the presented names belong to and/or are meant to refer to existing human beings. They were created using a "Random Name Generator".'
      button attributes: {"@click": "show = false"}, text: 'Hide'
    end
  end

end
```

All components inside the component's response are wrapped into a Vue.js conditional so they only get shown while the **show**-boolean is set to `true`. Upon clicking the button inside the component's response, this boolean gets set to `false` and therefore the whole component disappears - neat!

The last thing to do is adding the newly created dynamic component to `app/javascript/packs/application.js` so it gets correctly compiled by Webpack:

```javascript
import '../../matestack/components/person/disclaimer'
```

> need to register in component registry?

Start your application and see if it works! You should be able to click the 'Hide'-button below the disclaimer text and it disappears/gets hidden.

Note that it stays hidden when `matestack` page transition get performed, but re-appears on full page reloads. This was expected since the display/hide is performed purely on the client-side and, unlike a cookie or a configuration stored in a database, doesn't persist somewhere.

As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add app/javascript/packs/application.js app/matestack/components/person/ && git commit -m "Refactor disclaimer from static to dynamic custom component"
```

## Fetching and displaying data from 3rd party APIs

We want to display an option for what you could do with the person at its show page. Therefore we want to fetch a json api and display content of the responses on the page.

We can achieve this by creating a custom vue.js component. A custom vue.js component is different from a custom component in the way that it needs a corresponding javascript file, which implements the frontend counterpart of our custom vue.js component.

Okay, let's create our custom vue.js component. First we create a component in `app/matestack/components/persons/activity.rb`.

```ruby
class Components::Persons::Activity < Matestack::Ui::VueJsComponent

  def response
    div do
      paragraph do
        plain 'Need ideas on what to do with this person?'
        button text: 'Click here', attributes: {"@click": "addActivity()"}
      end
      ul attributes: {"v-if": "activities.length"} do
        li attributes: {"v-for": "activity,index in activities"} do
          plain "{{activity}}"
          button attributes: {"@click": "deleteActivity(index)"}, text: 'Remove'
        end
      end
    end
  end

end
```

Our vue.js component renders a div containing a paragraph and a list. The paragraph contains some text and a button. We set a `v-on:click` event handler like you would normally do in vue.js with its shorter version `@click`. This means the button will call the `addActivity` method from its corresponding vue.js component. In the list below we assume that our javascript vue.js component has an `activities` array. We loop over it, again using vue.js directives and display each activity with a button labelled 'Remove' which calls `deleteActivity(index)` if clicked.

Like stated above, a `Matestack::Ui::VueJsComponent` requires a javascript counterpart. Let's create it aside our ruby component in `app/matestack/components/persons/activity.js`

```javascript
MatestackUiCore.Vue.component('custom-person-activity', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {
      url: 'https://www.boredapi.com/api/activity/?participants=2',
      activities: []
    };
  },
  methods: {
    addActivity: function(){
      fetch(this.url, {
        headers: [
          ["Content-Type", "application/json"],
          ["Content-Type", "text/plain"]
        ]
      })
      .then(response => response.json())
      .then(data => this.activities.push(data.activity));
    },
    deleteActivity: function(position){
      this.activities.splice(position, 1);
    }
  }
});
```

As you can see, we're making use of [The Bored API](boredapi.com/) to 
fill an (initially empty) array with strings. The `addActivity` method calls the api and pushes the activity from the response into the activities array. Because vue.js is reactive, our list specified in the ruby component will be updated and contain the added activity. Clicking the delete button will remove the activity and therefore remove the entry from the list.

After creating the new component, we still need to register it, both in the `/app/matestack/components/registry.rb`

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    person_card: Components::Persons::Teaser,
    person_disclaimer: Components::Persons::Disclaimer,
    person_activity: Components::Persons::Activity
  )

end
```

and, since it's a dynamic component, we also need to add the javascript file to our `app/javascript/packs/application.js` like this

```javascript
// ...
import '../../matestack/components/person/activity'
```

Finally, we can use it in our show page!

```ruby
class Demo::Pages::Persons::Show < Matestack::Ui::Page

  def response
    transition path: persons_path, text: 'All Persons'
    heading size: 2, text: "Name: #{@person.first_name} #{@person.last_name}"
    paragraph text: "Role: #{@person.role}"

    onclick emit: 'show_more' do
      button text: 'Show more'
    end

    toggle show_on: 'show_more' do
      paragraph text: "Created at: #{I18n.l(@person.created_at)}"
      paragraph text: "Created at: #{I18n.l(@person.updated_at)}"
    end

    person_activity

    transition path: :edit_person_path, params: { id: @person.id }, text: 'Edit'
    action delete_person_config do
      button text: 'Delete person'
    end
  end

  #...

end
```

Spin up your app and head to the **Show** page to play around - fetching and deleting activities should work flawlessly! Hint: The way we have set it up for now, everything in this component happens on the client side and refreshing the page resets your activities to an empty array.

Again, don't forget to save your progress to Git. In the repo root, run

```sh
git add . && git commit -m "Add activity dynamic component to display activities from The Bored API"
```

## More information on custom vue.js components

The existing components inside matestack aim to cover as many use cases as possible, abstracting away most of the JavaScript for generic, recurring use cases. This way, you can stick to Ruby logic and focus on building instead of re-implementing basic JavaScript functionality. There sometimes is, however, a valid case for specific, handcrafted client side functionality. Therefore, matestack offers the option of creating custom vue.js components. Go ahead and [check the Vue.js guides](https://vuejs.org/v2/guide/) if you have never used it before.

As with custom components, there are hardly any limits for your creativity. You can also
- use `haml` (and in the future `slim` and `erb`) for templating
- use existing Vue.js mixins and JavaScript libraries (guides coming soon)
- use custom dynamic components to fetch, display, modify and update records from your database
- tweak and extend core components according to your situational, specific needs

To learn more, check out the [extend API documentation](docs/extend/custom_dynamic_components.md) for custom dynamic components.

## Recap & outlook

In this guide, we introduced custom vue.js components - an option for you to bring more complex JavaScript functionality to your application by extending matestacks components with your own Vue.js components.

Let's go ahead and learn how to best add [styling and notifications](/docs/guides/essential/10_styling_notifications.md) to our application in the next part of the series!
