A Single Page Application (SPA) usually is loaded once and handles all user
interactions dynamically by calling backend APIs. This gives the user the
ofted desired "app-feeling". Rails View Layer only offers the static request/response
mode to render content. matestack fixes that without adding the complexity a
SPA written in JavaScript usually brings with it. matestacks app instance simply
performs dynamic transitions between pages. You only have to follow the basic
structure to get this running:

## 1. Setup your matestack pages

First of all we need at least two matestack pages:

Your routes:

config/routes.rb

```ruby
Rails.application.routes.draw do
  get '/page1', to:'my_app#first_page', as: 'first_page'
  get '/page2', to:'my_app#second_page', as: 'second_page'
end
```

Your controller actions:

`app/controllers/my_app_controller.rb`

```ruby
class MyAppController < ApplicationController

  include Matestack::Ui::Core::ApplicationHelper

  def first_page
    responder_for(Pages::MyApp::MyExamplePage)
  end

  def second_page
    responder_for(Pages::MyApp::MySecondExamplePage)
  end

end
```

*Note: As you see, controller action names don't have to match the page class name.*

Now we define our matestack pages:

`app/matestack/pages/my_app/my_example_page.rb`

```ruby
class Pages::MyApp::MyExamplePage < Matestack::Ui::Page

  def response
    components {
      div do
        span do
          plain "This is Page 1!"
        end
      end
    }
  end

end
```

and

`app/matestack/pages/my_app/my_second_example_page.rb`

```ruby
class Pages::MyApp::MySecondExamplePage < Matestack::Ui::Page

  def response
    components {
      div do
        span do
          plain "This is Page 2!"
        end
      end
    }
  end

end
```

*Note: the page class name has to match your file name and the apps name has to match the namespace of your matestack page*

- Pages::**MyApp**::MyExamplePage --> `app/matestack/pages/my_app/my_example_page.rb`
- Pages::**MyApp**::MySecondExamplePage `app/matestack/pages/my_app/my_second_example_page.rb`

## 2. Add transition links to your app

Now we have to add transition links to your matestack app.

`app/matestack/apps/my_app.rb`

```ruby
class Apps::MyApp < Matestack::Ui::App

  def response
    components {
      header do
        heading size: 1, text: "My App"
      end

      nav do

        # perform a dynamic transition to a different page
        # the links get the class "active" when their path is active
        transition path: :first_page_path, text: "First Page", class: "nav-link"

        # or with a button for example
        transition path: :second_page_path, class: "nav-link" do
          button do
            plain "Second Page"
          end
        end

      end

      main do
        yield_page
      end
    }
  end

end
```

Clicking on the transition links will perform dynamic transition and change the
yield_page without a full page reload.

You can see this in action when navigating through this guides. The links on the
sidebar of these docs are transition components.

## Recap

We've implemented a dynamic SPA with a few lines of Ruby. No JavaScript was required.
On the next section, we will learn how to add some custom UI Sugar in order to perform
a smooth page transition!

### Handle Page Transition Events

On the previous section we learned, how to implement dynamic page transitions in pure
Ruby. matestack wants to cover the basic dynamic behavior of your Web-App with
minimum complexity. You should be able to add custom UI Goodies on top of this
solid structure though. To give you maximum flexibility, you can use classic JavaScript
and a Vue.js EventBus for that.

We now want to add a nice loading transition when the user navigates between pages.

matestack emits vue.js events on specific UI interactions. If you receive these events,
you can do all kinds of DOM-Manipulations. **Let's see, how
page transition effects as on this documentation app are implemented, for example.**

(We're using Material Design Light, you could use whatever you want)

`app/matestack/apps/my_app.rb`

```ruby
class Apps::MyApp < Matestack::Ui::App

  def response
    components {
      #...
      main do
        div class: "loading" do
          div id: "spinner", class: "mdl-spinner mdl-js-spinner is-active"
        end
        div id: "yield_page" do
          yield_page
        end
        partial :alert_bar  #optional
      end
      #...
    }
  end

  #optional
  def alert_bar
    partial {
      div id: "alert_bar", class: "mdl-js-snackbar mdl-snackbar mdl-snackbar--alert" do
        div class: "mdl-snackbar__text"
        div class: "mdl-snackbar__action"
      end
    }
  end

end
```

Now let's add some custom JavaScript behavior (just pick what you want to use on your project and adapt to your DOM):

**Note 1: All the DOM Manipulations below may depend on your custom DOM structure/CSS Framework**

**Note 2: In v0.7.3 we aditionally will offer a component handling most of these effects, making it easier to apply a nice page transition to your component with less JS** 

`app/assets/javascripts/application.js`

```javascript
//Transition Start - DOM Manipulation (depends on your DOM/CSS Framework!)
MatestackUiCore.matestackEventHub.$on('page_loading', function(url){
  //hide old content
  document.querySelector('#yield_page').style.opacity = 0;
  setTimeout(function () {
    //show loading spinner
    document.querySelector('#spinner').style.display = "inline-block";
  }, 300);
});

//Transition End - DOM Manipulation (depends on your DOM/CSS Framework!)
MatestackUiCore.matestackEventHub.$on('page_loaded', function(url){
  setTimeout(function () {
    //hide loading spinner
    document.querySelector('#spinner').style.display = "none";
    //show new content
    document.querySelector('#yield_page').style.opacity = 1;
  }, 500);
});

//Transition End Scroll Top (depends on your DOM/CSS Framework!)
MatestackUiCore.matestackEventHub.$on('page_loaded', function(url){
  //scroll top in order to display new content at top position
  document.getElementsByTagName("main")[0].scrollTop = 0
})

//Transition End Material Snackbar API Call (depends on your DOM/CSS Framework!)
MatestackUiCore.matestackEventHub.$on('page_loaded', function(url){
  setTimeout(function () {
    var noticebarContainer = document.querySelector('#notice_bar');
    var data = {message: 'loaded: ' + url, timeout: 1500};
    noticebarContainer.MaterialSnackbar.showSnackbar(data)
  }, 500);
})

//Transition Error DOM Manipulation and Material Snackbar API Call (depends on your DOM/CSS Framework!)
MatestackUiCore.matestackEventHub.$on('page_loading_error', function(error){
  setTimeout(function () {
    //hide loading spinner
    document.querySelector('#spinner').style.display = "none";
    //show old content again
    document.querySelector('#yield_page').style.opacity = 1;
    //call Material Snackbar API
    var alertbarContainer = document.querySelector('#alert_bar');
    var data = {message: 'error loading: ' + error.config.url, timeout: 3000};
    alertbarContainer.MaterialSnackbar.showSnackbar(data)
  }, 500);
})


```

and a some CSS:

`app/assets/stylesheets/application.css`

```css
#yield_page{
  transition:opacity 0.2s linear;
}
#spinner {
  display: none; //init hide
}
```
