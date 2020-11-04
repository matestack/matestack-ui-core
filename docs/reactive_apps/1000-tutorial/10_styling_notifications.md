# Essential Guide 8: Styling and Notifications

Demo: [Matestack Demo](https://demo.matestack.io)<br>
Github Repo: [Matestack Demo Application](https://github.com/matestack/matestack-demo-application)

Welcome to the tenth part of our tutorial about building a web application with matestack.

## Introduction

After introducing Vue.js components in the [previous guide](/docs/reactive_apps/1000-tutorial/09_custom_vue_js_components.md), it's time to work on the appearance and user experience of the application.

In this guide, we will
- install and set up the popular UI toolkit [Bootstrap](https://getbootstrap.com/)
- add styling to the existing pages and components using bootstrap
- cover the best practice for styling custom components
- add bootstrap notification badges
- finish of the changes by adding a loading spinner for matestack page transitions

**Note:** This guide uses Rails 6 and Webpack. If you're using the Asset Pipeline in your application, please head to the Asset Pipeline section [at the bottom of this page](#bootstrap-asset-pipeline).

This guide is heavily inspired by [Ross Kaffenberger's guide on *Using Bootstrap with Rails Webpacker*](https://rossta.net/blog/webpacker-with-bootstrap.html).

## Prerequisites

We expect you to have successfully finished the [previous guide](/docs/reactive_apps/1000-tutorial/09_custom_vue_js_components.md).

## Installing Bootstrap

Let's kick it off by running `yarn add bootstrap` to install Bootstrap. Then, create a file called `custom-bootstrap.scss` in `app/javascript/css/` and add the following line

```css
@import "~bootstrap/scss/bootstrap.scss";
```

to import it. The only missing part now is importing this file in to the existing `app/javascript/packs/application.js` file.

```js
import 'css/custom-bootstrap'
```

## Installing jQuery

Bootstrap requires jQuery and popper.js, so now is a good time to add those dependencies. Install it by runnning `yarn add jquery popper.js`.

Afterwards import all JavaScript dependencies of bootstrap and bootstraps own JavaScript in the `app/javascript/packs/application.js` by adding the following lines to it.

```js
import 'jquery'
import 'popper.js'
import 'bootstrap'
```

## Starting to style the application

Before we begin putting bootstrap to use, we need to prepare the `app/view/layouts/application.html.erb` for responsive use by adding the appropiate meta tag. Therefore we update the `<head>` section of our `app/views/layouts/application.html.erb`.

```html
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <title>Matestack Demo Application</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_pack_tag 'application', media: 'all' %>
  <%= javascript_pack_tag 'application' %>
</head>
```

Let's save our changes by running

```sh
git add . && git commit -m "Install Bootstrap, jQuery, update application.html.erb"
```

In the next step we arrange and style the contents of our app and pages using bootstrap. We also refactor our app and pages with partials and components where necessary.

`app/matestack/demo/app.rb`

```ruby
class Demo::App < Matestack::Ui::App

  def response
    navigation
    main id: 'page-content' do
      person_disclaimer
      yield_page
    end
    footer
  end

  private

  def navigation
    nav class: 'navbar navbar-expand-md navbar-light bg-white fixed-top' do
      transition class: 'navbar-brand font-weight-bold text-primary', path: root_path, text: 'DemoApp'
      navbar_button
      div id: 'navbar-default', class: 'collapse navbar-collapse' do
        ul class: 'navbar-nav mr-auto' do
          li class: 'nav-item' do
            transition class: 'nav-link text-dark', path: persons_path, text: 'Persons'
          end
          li class: 'nav-item' do
            transition class: 'nav-link text-dark', path: new_person_path, text: 'New'
          end
          li class: 'nav-item' do
            link class: 'nav-link text-secondary', path: new_admin_session_path, text: 'Login'
          end
        end
      end
    end
  end

  def navbar_button
    button(
      class: 'navbar-toggler text-dark', role: :button,
      data: { target: '#navbar-default', toggle: :collapse },
      attributes: { "aria-controls": "navbar-default", "aria-expanded": "false" }
    ) do
      span class: 'navbar-toggler-icon text-dark'
    end
  end

  def footer
    div class: 'jumbotron jumbotron-fluid bg-light mb-0 footer' do
      div class: 'container py-5' do
        div class: 'd-flex align-items-center justify-content-center' do
          heading class: 'm-0 mr-1 font-weight-normal', size: 5, 
            text: 'This demo application and corresponding guides are provided by'
          img path: asset_path('matestack'), height: '48px'
        end
      end
    end
  end

end
```

We extracted our navigation into a partial and added a footer as a partial. Both are styled with bootstrap. Because it is quite complex, we also excluded the navigation toggle button for the responsive navigation into a partial called `navbar_button`.

Next we style our person index page. Below you can see the updated file styled with bootstrap.

`app/matestack/demo/pages/persons/index.rb`

```ruby
class Demo::Pages::Persons::Index < Matestack::Ui::Page
  include Matestack::Ui::Core::Collection::Helper

  def prepare
    person_collection_id = "person-collection"
    current_filter = get_collection_filter(person_collection_id)
    current_order = get_collection_order(person_collection_id)

		person_query = Person.all
    filtered_person_query = person_query
    .where("last_name LIKE ?", "%#{current_filter[:last_name]}%")
		.order(current_order)

    @person_collection = set_collection({
      id: person_collection_id,
      data: filtered_person_query,
			init_limit: 6,
			filtered_count: filtered_person_query.count,
			base_count: person_query.count
    })
  end

  def response
    jumbotron_header title: 'All your persons'
  
    div class: 'container overlap-container' do
      div class: 'shadow'
      div class: 'row pt-4' do
        div class: 'col-md-8' do
          filter
        end
        div class: 'col-md-4' do
          ordering
        end
      end
      async rerender_on: 'person-collection-update', id: 'person-collection' do
        content
      end
    end

    div class: 'jumbotron jumbotron-fluid text-secondary mt-5 text-center mb-0' do
      div class: 'container py-3' do
        heading text: 'You know another person?'
        div class: 'col-md-12 text-center my-3' do
          transition path: new_person_path, class: 'my-3 btn btn-primary btn-lg', text: 'Add one', delay: 300
        end
      end
    end
  end

  def filter
    collection_filter @person_collection.config do
      div class: 'd-flex' do
        collection_filter_input key: :last_name, type: :text, placeholder: 'Filter by Last name', class: 'form-control'
        collection_filter_submit do
          button class: 'btn btn-outline-primary ml-1', text: 'Apply'
        end
        collection_filter_reset do
          button class: 'btn btn-outline-secondary ml-1', text: 'Reset'
        end
      end
    end
  end

	def ordering
    collection_order @person_collection.config do
      div class: 'form-group d-flex justify-content-end' do
        label text: 'Sorted by:', class: 'col-form-label'
        div do
          collection_order_toggle key: :last_name do
            button class: 'btn btn-primary ml-2' do
              collection_order_toggle_indicator key: :last_name, 
                asc: 'Last name (A-Z)', desc: 'Last name (Z-A)', default: 'Date of creation'
            end
          end
        end
      end
    end
	end

  def content
    collection_content @person_collection.config do
      @person_collection.paginated_data.each do |person|
        person_teaser person: person
      end
      div class: 'row' do
        paginator
      end
    end
  end

	def paginator
    div class: 'col-md-12 text-center mt-5' do
      div class: 'p-2' do
        paginator_description
      end
      ul class: 'pagination' do
        li class: 'page-item' do
          collection_content_previous do
            div class: 'page-link' do
              span attributes: { 'aria-hidden': true }, text: '&laquo;'.html_safe
            end
          end
        end
        @person_collection.pages.each do |page|
          li class: 'page-item' do
            collection_content_page_link page: page do
              button class: 'page-link', text: page
            end
          end
        end
        li class: 'page-item' do
          collection_content_next do
            div class: 'page-link' do
              span attributes: { 'aria-hidden': true }, text: '&raquo;'.html_safe
            end
          end
        end
      end
    end
  end

  def paginator_description
    plain "Showing persons #{@person_collection.from}"
    plain "to #{@person_collection.to}"
    plain "of #{@person_collection.filtered_count}"
    plain "from a total of #{@person_collection.base_count} records."
  end

end
```

As you see, we added a custom component called `jumbotron_header`. It is used on every page with different headlines, or without a headline. Because we reuse it, we extracted it into a custom component defined in `app/matestack/components/shared/jumbotron_header.rb`. And registered it in our registry as `jumbotron_header: Components::Shared::JumbotronHeader`. We called it jumbotron header because it uses bootstraps jumbotron component.

```ruby
class Components::Shared::JumbotronHeader < Matestack::Ui::Component

  optional :title

  def response
    div jumbotron_options do
      div class: 'container py-5' do
        heading text: title, class: 'pt-5'
      end
    end
  end

  private

  def jumbotron_options
    {
      class: 'jumbotron jumbotron-fluid text-secondary', 
      style: "background-image: url('#{image_path('background')}');"
    }
  end

end
```

Quite a simple component. To keep it more readable we extracted the hash argument for the first div into a method `jumbotron_options` which returns a hash with the needed classes and styling for a background image.

In order to make our jumbotron and our content looking really good, we need some CSS. We want to overlap our list of person with the jumbotron and add a small shadow in order to make the overflow stand out.

Therefore we add a file called `application.scss` in `app/javascripts/css/`. We will add some styles to it in order to achieve our overflow effect and some general styles for our app. For example making our footer always appear at the bottom of the page no matter how less content there might be on a page.

```scss
html {
  height: 100%;
}

body {
  position: relative;
  min-height: 100%;
  padding-bottom: 270px;
}

main {
  padding-top: 56px;
}

.jumbotron-fluid {
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center center;
}

.overlap-container {
  margin-top: -7rem;
  background: white;
  position: relative;

  &> * {
    background: white;
    position: relative;
    z-index: 2;
  }

  .shadow {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 55px;
  }

}

.footer {
  position: absolute;
  width: 100%;
  bottom: 0;
}

.errors {
  display: block;
  color: #FF3B14;
}

.nav-link {
  white-space: nowrap;
}
```

Like our custom bootstrap scss file we need to import our `application.scss` file in our `app/javascript/packs/application.js` file.

```js
// ...
import 'css/custom-bootstrap'
import 'css/application'
// ...
```

Now we can refactor and style all other person pages. Feel free to experiment and style on your own or take a look at the repository to review our changes to the pages.

## Overwriting Bootstrap default styles

We only used bootstraps components and therefore just got the well known bootstrap look and feel. In order to make our application really our own we will go on and theme bootstrap accordingly. Learn more about how and what you can theme or customize in bootstrap by reading the [bootstrap documentation](https://getbootstrap.com/docs/4.5/getting-started/theming/). 
In the next step we change the default color scheme of bootstrap by overriding a few CSS variables or maps.
Pay attention, all your overrides need to happen before the `@import` statement. 

`app/javascript/css/custom-bootstrap.scss`

```scss
$darkest-orange: #FF3B14;
$light-orange: #fecdc3;

$lightest-grey: #F4F4F5;
$dark-grey: #A4A4AE;
$darkest-grey: #1B1D35;

$darkest-blue: #1b1d35;
$darker-blue:#606171;

$body-bg: white;
$body-color: $darkest-grey;

$theme-colors: (
  "primary": $darkest-orange,
  "secondary": $darker-blue,
  "info": $light-orange,
  "warning": $dark-grey,
  "dark": $darkest-blue,
  "light": $lightest-grey,
);

@import "~bootstrap/scss/bootstrap.scss";
```

## Styling custom components

We styled our app and pages. The last thing missing is styling of our custom components. As an example we refactor, style and upgrade our disclaimer component. We introduced it a while ago to give an example how we can use `.haml` files with components. But because we want to add the functionality to hide the disclaimer by clicking a button and we don't need a custom `.haml` file, we will remove it now. Afterwards we update our disclaimer component to contain a bootstrap alert and make it hideable.

`app/matestack/components/persons/disclaimer.rb`

```ruby
class Components::Persons::Disclaimer < Matestack::Ui::Component

  def response
    toggle hide_on: 'hide_disclaimer' do
      div class: 'disclaimer-component container-fluid text-center shadow-md' do
        disclaimer_text
        onclick emit: 'hide_disclaimer' do
          button class: 'btn', attributes: {"@click": "show = false"}, text: 'Hide'
        end
      end
    end
  end

  def disclaimer_text
    span text: 'None of the presented names belong to and/or are meant to refer to existing human beings. 
      They were created using a "Random Name Generator".'
  end

end
```

As you can see, we used the earlier introduced toggle component in order to hide the disclaimer if a user presses the "Hide" button, which emits the appropriate event for the toggle component.

In order to make our disclaimer float over our jumbotron header underneath the navigation we need to style it with some CSS. In order to keep our code clean and create scope-like styles we recommend a best practice for file locations and stylings. First the file location. We recommend to create the SCSS file right next to your component. In the case of the disclaimer component this would be `app/matestack/components/persons/disclaimer.scss`. Let's create that file and import it in our `custom-bootstrap.scss` with `@import '../../matestack/components/persons/disclaimer';`. By adding it below our bootstrap import, we can make use of bootstraps variables, breakpoints and more (like **md** in `@include media-breakpoint-down(md)`).

In order to keep our styles for the disclaimer from affecting other elements, we recommend to add a unique class to the most outer element of your component. In our case we will add a class `.disclaimer-component` to the child `div` of the `toggle` component. The line should now look like this: 
```ruby
div class: 'disclaimer-component container-fluid text-center shadow-md' do
```

In our SCSS file we will only add styles inside of the selector `.disclaimer-component`. This will prevent us from overriding styles of other elements by mistake. Now let's style our disclaimer by adding the following content to our SCSS file:

```scss
.disclaimer-component {
  position: absolute;
  width: 90%;
  left: 5%;
  margin-top: 10px;
  background-color: #fecdc3;
  border-radius: 5px;
  color: $darkest-blue;
  padding: 1rem 3rem 1rem 1rem;

  span {
    padding: 0 3rem;
    display: block;
  }

  .btn {
    position: absolute;
    top: .5rem;
    right: 1rem;
    line-height: 1.5;
    padding: 0.5rem 1rem;
    background: rgba(#ff7d63, 0.5);


    @include media-breakpoint-down(md) {
      display: block;
      margin-top: 5px;
      margin-left: auto;
      margin-right: auto;
    }
  }
}
```

## Adding page transition animations

Okay, now that our application is styled and customized we can take a look at the user experience. Using `transition` components inside an app increased the user experience already quite a lot by making the website feel more like an app. But what about smooth transitions between pages of our app. Matestack provides us with an easy to use solution to implement subtle animations, for example a loading spinner between page loads.

We simply need to add a `loading_state` slot to our `yield_page` call in our demo app. The yield_page call now gets passed in `slots` as a hash. Inside the hash we set the value of the `loading_state` calling a partial. The partial `loading_state_element` contains a simple bootstrap spinner.

```ruby
class Demo::App < Matestack::Ui::App

  def response
    navigation
    main id: 'page-content' do
      person_disclaimer
      yield_page slots: { loading_state: loading_state_element }
    end
    footer
  end

  private

  def navigation
    # ...
  end

  def navbar_button
    # ...
  end

  def footer
    # ...
  end

  def loading_state_element
    slot do
      div id: 'spinner', class: 'spinner-border', role: 'status' do
        span class: 'sr-only', text: 'Loading...'
      end
    end
  end

end
```

To better understand what we achieve with this let's take a look at matestacks DOM structure for pages, when you pass in a `loading_state` slot.

```html
<div class="matestack-page-container">
  <div class="loading-state-element-wrapper"></div>
  <div class="matestack-page-wrapper">
    <!-- Your page content -->
  </div>
<div>
```

The `.loading-state-element-wrapper` div will only be rendered if a `loading_state` slot is defined. It contains the defined element, in our case our bootstrap loading spinner. The `.matestack-page-wrapper` div contains the page content. If we now visit the root page, we will see a spinner above our page content. This is because we have not yet added the required rules to hide it unless the page is actually reloading. If a page transition happens and the page is reloaded, all the above elements will get a `.loading` class added. We can use this to add a simple page transition animation.

In order to do that, we add another SCSS file in `app/javascript/css/page-transition.scss` and import it in our `application.js` with `import 'css/page-transition'`. Here we will define the default styles for our loading element and page content. Our loading element should normally be invisible and our page content should be visible. If a `.loading` class is applied we want to hide the page content and show our loading element. We can achieve this with the following rules and add a smooth animation between the show and hide states.

```scss
.matestack-page-container{
  .loading-state-element-wrapper{
    position: fixed;
    height: 40px;
    width: 40px;
    left: calc(50vw - 20px);
    top: calc(50vh - 20px);
    opacity: 0;
    overflow: hidden;
    transition: opacity 0.3s ease-in-out;

    &.loading {
      opacity: 1;
    }
  }

  .matestack-page-wrapper {
    opacity: 1;
    transition: opacity 0.2s ease-in-out;

    &.loading {
      opacity: 0;
    }
  }
}
```

If you now take a look at your application in the browser and click a transition link, you may see the animation, but only very short or maybe not at all. This is due to the fact that our page is reloaded to fast in order to fully appreciate our animation. To smooth the animation we could add a delay to our transitions with the `delay` option. This will delay the reload by a given time in milliseconds, which will give us and the user time to see the animation, preventing unwanted flickering. But be careful, don't choose a big delay, as users might get upset by to long animations.

## Recap & outlook

In this guide we learned how to use bootstrap with matestack in order to style an application, how to customize bootstrap, a best practice about styling components and how we can add animations between page transitions.

Going ahead, the next part of this series covers [authentication via Devise](/docs/reactive_apps/1000-tutorial/11_authentication_devise.md).

<br>
<br>
<hr id="bootstrap-asset-pipeline">
<br>
<br>

## Using the Asset Pipeline instead of Webpack(er)
If you're using the Asset Pipeline in your application, using Bootstrap to style your `matestack` pages and components also works very well - you only need to take a slightly different route while setting things up!

### Installing Bootstrap and jQuery
Add the following lines to your Gemfile

```ruby
gem 'bootstrap'
gem 'jquery-rails'
```

and run `bundle install`. Afterwards, change `app/assets/stylesheets/appplciation.css` to `app/assets/stylesheets/appplciation.scss` and import Bootstrap by adding the follwing line:

```css
@import "bootstrap";
```

To use jQuery and various Bootstrap JavaScript plugins, add the following lines to your `application.js`:

```js
//= require jquery3
//= require popper
//= require bootstrap-sprockets
```

Now, we're good to go concerning the underlying libraries. Further information can be found on the [Bootstrap Gem Site](https://github.com/twbs/bootstrap-rubygem).

### Styling matestack custom components and pages
Since we want to put the `.scss`-files for our custom components right next to the component definition in `app/matestack/components/`, we need to update our `config/initializers/assets.rb` configuration by adding the following line:

```ruby
Rails.application.config.assets.paths << Rails.root.join('app/matestack/components')
```

Now, in the `app/assets/stylesheets/appplciation.scss`, you can import custom component stylesheets by importing them, respecting potential namespaces. The example from above would look like this:

```css
@import "persons/disclaimer";
```

From our experience, it makes sense to create a `app/assets/stylesheets/pages/` directory, containing a `.scss`-file for every `matestack` page, and then structure `app/assets/stylesheets/appplciation.scss` like this:

```css
// file containing various SASS variables
// specifying the project design
@import "ci";
// file containing customized bootstrap variables
@import "bootstrap_override";
// default bootstrap import
@import "bootstrap";

// pages
@import "pages/example";
...
@import "pages/demo";

// components
@import "example/component";
...
@import "demo/dynamicComponent";
```
