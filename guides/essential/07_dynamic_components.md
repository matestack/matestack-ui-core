# Essential Guide 7: Custom Dynamic Components
Welcome to the seventh part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
In the [previous guide](guides/essential/06_static_components.md), we introduced custom static `matestack` components. In this one, we're bringing it to the next level with custom dynamic `matestack` components!

In this guide, we will
- refactor the `disclaimer` component to be a custom dynamic `matestack` component
- adding a custom dynamic `matestack` component that fetches and displays data from a 3rd-party API

## Prerequisites
We expect you to have successfully finished the [previous guide](guides/essential/06_static_components.md) and no uncommited changes in your project.

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

Start your application and see if it works! You should be able to click the 'Hide'-button below the disclaimer text and it disappears/gets hidden.

Note that it stays hidden when `matestack` page transition get performed, but re-appears on full page reloads. This was expected since the display/hide is performed purely on the client-side and, unlike a cookie or a configuration stored in a database, doesn't persist somewhere.

As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add app/javascript/packs/application.js app/matestack/components/person/ && git commit -m "Refactor disclaimer from static to dynamic custom component"
```

## Fetching and displaying data from 3rd party APIs
Let's tackle a more challenging task: Fetching JSON from an API and displaying it via a custom dynamic component!

Below you can see the code for the next custom dynamic component, living in `app/matestack/components/person/activity.js`:

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

As you can see, we're making use of [The Bored API](boredapi.com/) to fill an (initially empty) array with strings. Now, we need to add the main component file in `app/matestack/components/person/activity.rb` with the following content:

```ruby
class Components::Person::Activity < Matestack::Ui::DynamicComponent

  def response
    div do
      paragraph do
        plain 'Need ideas on what to do with one of these persons?'
        button attributes: {"@click": "addActivity()"}, text: 'Click here'
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

Same as in the example above, we trigger a JavaScript function by clicking a button. This time, it fetches data from a URL and appends the relevant part of the response to the activities array. As long as this array isn't empty, its content gets displayed as a list, each list item featuring a `delete` button.

After creating the new component, we still need to register it, both in the `/app/matestack/components/registry.rb`

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    person_card: Components::Person::Card,
    person_card: Components::Person::Disclaimer,
    person_card: Components::Person::Activity
  )

end
```

and, since it's a dynamic component, also in `app/javascript/packs/application.js` like this

```javascript
// ...
import '../../matestack/components/person/activity'
```

Finally, we can put it to one of our pages! Let's add it to the bottom of the **Show** page's `response` method:

```ruby
def response
  # ...
  partial :other_persons
  person_activity
end
```

Spin up your app and head to the **Show** page to play around - fetching and deleting activities should work flawlessly! Hint: The way we have set it up for now, everything in this component happens on the client side and refreshing the page resets your activities to an empty array.

Again, don't forget to save your progress to Git. In the repo root, run

```sh
git add app/javascript/packs/application.js app/matestack/demo/pages/persons/show.rb app/matestack/components/person/ app/matestack/components/registry.rb && git commit -m "Add activity dynamic component to display activities from The Bored API"
```

## More information on custom dynamic components
The existing dynamic core components inside `matestack-ui-core` aim to cover as many use cases as possible, abstracting away most of the JavaScript for generic, recurring use cases. This way, you can stick to Ruby logic and focus on building instead of re-implementing basic JavaScript functionality. There sometimes is, however, a valid case for specific, handcrafted client side functionality. Therefor, `matestack` offers the option of creating custom dynamic components, built as custom Vue.js components. Go ahead and [check the Vue.js guides](https://vuejs.org/v2/guide/) if you have never used it before.

As with custom static components, there are hardly any limits for your creativity! You can use also
- use `haml` (and in the future `slim` and `erb`) for templating
- use existing Vue.js mixins and JavaScript libraries (guides coming soon)
- use custom dynamic components to fetch, display, modify and update records from your database
- tweak and extend core components according to your situational, specific needs

To learn more, check out the [extend API documentation](docs/extend/custom_dynamic_components.md) for custom dynamic components.

## Deployment
After you've finished all your changes and commited them to Git, run

```sh
git push heroku master
```

to deploy your latest changes. Check the results via

```sh
heroku open
```

and check that it still works as expected!

## Recap & outlook
In this guide, we introduced custom dynamic components - an option for you to bring fancy JavaScript functionality to your application by extending `matestack-ui-core` with Vue.js components.

But as we could only cover so much ground in this guide, so make sure to spend some more time tweaking the recently added features!

Let's go ahead and learn how to best add [styling and notifications](/guides/essential/08_styling_notifications.md) to our application in the next part of the series!
