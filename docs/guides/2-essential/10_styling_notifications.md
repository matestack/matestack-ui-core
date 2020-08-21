# Essential Guide 8: Styling and Notifications

Welcome to the tenth part of our essential guide about building a web application with matestack.

## Introduction

After introducing vue.js components in the [previous guide](/docs/guides/2-essential/09_custom_vue_js_components.md), it's time to work on the appearance and user experience of the application.

In this guide, we will
- install and set up the popular UI toolkit [Bootstrap](https://getbootstrap.com/)
- add styling to the existing pages and components using bootstrap
- cover the best practice for styling custom components
- add bootstrap notification badges
- finish of the changes by adding a loading spinner for matestack page transitions

**Note:** This guide uses Rails 6 and Webpack. If you're using the Asset Pipeline in your application, please head to the Asset Pipeline section [at the bottom of this page](#bootstrap-asset-pipeline).

This guide is heavily inspired by [Ross Kaffenberger's guide on *Using Bootstrap with Rails Webpacker*](https://rossta.net/blog/webpacker-with-bootstrap.html).

## Prerequisites

We expect you to have successfully finished the [previous guide](guides/essential/09_custom_vue_js_components.md).

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

Afterwards import all javascript dependencies of bootstrap and bootstraps own javascript in the `app/javascript/packs/application.js` by adding the following lines to it.

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

  <%= stylesheet_pack_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
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
    div id: 'spinner', class: 'spinner-border', role: 'status' do
      span class: 'sr-only', text: 'Loading...'
    end
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
      class: 'navbar-toggler text-dark',
      role: :button,
      attributes: {
        "aria-controls": "navbar-default",
        "aria-expanded": "false",
        data: { target: '#navbar-default', toggle: :collapse },
      }
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
      async rerender_on: 'person-collection-update' do
        content
      end
    end

    div class: 'jumbotron jumbotron-fluid text-secondary mt-5 text-center mb-0' do
      div class: 'container py-3' do
        heading text: 'You know another person?'
        div class: 'col-md-12 text-center my-3' do
          transition path: new_person_path, class: 'my-3 btn btn-primary btn-lg', text: 'Add one'
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
      attributes: { style: "background-image: url('#{image_path('background')}');" }
    }
  end

end
```

----
# Refactor from here
paste in the whole code!
maybe don't show every updated page, just tell them to look in the repo.
rework component styling to state that we advise to do it like that as best practice
  use disclaimer component as example
----

`app/matestack/demo/pages/persons/show.rb`
```ruby
# ...
  def response
    section do
      div class: 'container' do
        transition path: persons_path, class: 'btn btn-secondary', text: 'All persons'

        div class: 'row' do
          div class: 'col-md-6 offset-md-3 text-center' do
            heading size: 2, text: "Name: #{@person.first_name} #{@person.last_name}"
            paragraph text: "Role: #{@person.role}"
            transition path: :edit_person_path, params: { id: @person.id }, class: 'btn btn-secondary', text: 'Edit'
            action delete_person_config do
              button class: 'btn btn-warning', text: 'Delete person'
            end
          end
        end
      end
    end

    other_persons
    person_activity
  end

  def other_persons
    section do
      div class: 'container' do
        div class: 'row' do
          div class: 'col-md-12 text-center' do
            heading size: 3, text: 'Three other persons:'
          end
          @other_persons.each do |person|
            div class: 'col-md-4' do
              person_card person: person
            end
          end
        end
      end
    end
  end
# ...
```

`app/matestack/demo/pages/persons/edit.rb`
```ruby
# ...
  def response
    section do
      div class: 'container' do
        div class: 'row' do
          div class: 'col-md-6 offset-md-3 text-center' do
            heading size: 2, text: "Edit Person: #{@person.first_name} #{@person.last_name}"
            form person_edit_form_config, :include do
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'First name:'
                div class: 'col-sm-8' do
                  form_input key: :first_name, class: 'form-control', type: :text
                end
              end
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Last name:'
                div class: 'col-sm-8' do
                  form_input key: :last_name, class: 'form-control', type: :text
                end
              end
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Person role:'
                div class: 'col-sm-8' do
                  form_select key: :role, type: :dropdown, class: 'form-control', options: Person.roles.keys, init: @person.role
                end
              end
              form_submit do
                transition path: :person_path, params: { id: @person.id }, class: 'btn btn-secondary my-3', text: 'Back to detail page'
                button class: 'btn btn-primary', text: 'Save changes'
              end
            end
          end
        end
      end
    end
  end
# ...
```

`app/matestack/demo/pages/persons/new.rb`
```ruby
# ...
def response
  section do
    div class: 'container' do
      div class: 'row' do
        div class: 'col-md-6 offset-md-3 text-center' do
          heading size: 2, text: 'Create new person'
          form new_person_form_config, :include do
            div class: 'form-group row' do
              label class: 'col-sm-4 col-form-label col-form-label-md', text: 'First name:'
              div class: 'col-sm-8' do
                form_input key: :first_name, class: 'form-control', type: :text
              end
            end
            div class: 'form-group row' do
              label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Last name:'
              div class: 'col-sm-8' do
                form_input key: :last_name, class: 'form-control', type: :text
              end
            end
            div class: 'form-group row' do
              label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Person role:'
              div class: 'col-sm-8' do
                form_select key: :role, type: :dropdown, class: 'form-control', options: Person.roles.keys, init: Person.roles.keys.first
              end
            end
            form_submit do
              transition path: persons_path, class: 'btn btn-secondary my-3', text: 'All persons'
              button class: 'btn btn-primary', text: 'Create person'
            end
          end
        end
      end
    end
  end
end
# ...
```

Spin up your application by running `rails s` and check how things are looking now! Some improvements happening, but still quite a way to go.

Let's move on and add a file called `application.scss` in `app/javascript/css/`, making some minor adjustments:

```css
main {
  padding-top: 56px;
}

section {
  padding: 1.5em 0;
}

.pagination {
  justify-content: center;
}

h2 {
  margin-top: 2rem;
  margin-bottom: 3rem;
}

.card {
  margin-top: 1rem;
  margin-bottom: 1rem;
}
```

Like with the `custom-bootstrap`-file, we need to import it in `app/javascript/packs/application.js`:

```js
// ...
import 'css/custom-bootstrap'
import 'css/application'
// ...
```

## Overwriting Bootstrap default styles
Except for the few changes in `application.scss`, our application still has the basic bootstrap look. We can quite easily customize the default settings by overriding variables right before the `@import`-statement in `app/javascript/css/custom-bootstrap.scss`. This is one example, but feel free to replace the colors with ones you like better:

```css
$matestack-darkest-orange: #FF3B14;

$matestack-lightest-grey: #F4F4F5;
$matestack-dark-grey: #A4A4AE;
$matestack-darkest-grey: #1B1D35;

$body-bg: $matestack-lightest-grey;
$body-color: $matestack-darkest-grey;

$theme-colors: (
  "primary": $matestack-darkest-orange,
  "secondary": $matestack-darkest-grey,
  "info": $matestack-darkest-grey,
  "warning": $matestack-dark-grey
);

@import "~bootstrap/scss/bootstrap.scss";
```

Before we take care of styling the custom components, let's commit our local changes by running

```sh
git add . && git commit -m "Make demo app & pages use bootstrap classes, customize bootstrap"
```

## Styling custom components
Both our application and the pages are styled, and the only thing missing are the custom components - so let us style those!

Update the response methods in `app/matestack/components/persons/teaser.rb` and `app/matestack/components/persons/activity.rb` to resemble the following:

```ruby
  # card.rb
  def response
    div class: 'card' do
      div class: 'card-body' do
        paragraph text: "#{@person.first_name} #{@person.last_name}"
        transition path: :person_path, params: {id: @person.id}, class: 'btn btn-primary', text: 'Details'
      end
    end
  end

  # activity.rb
  def response
    section do
      div class: 'container' do
        div class: 'row' do
          div class: 'col-md-6 offset-md-3' do
            paragraph class: 'text-center' do
              plain 'Need ideas on what to do with one of these persons?'
              button attributes: {"@click": "addActivity()"}, class: 'btn btn-primary', text: 'Click here'
            end
            ul attributes: {"v-if": "activities.length"}, class: 'list-group' do
              li attributes: {"v-for": "activity,index in activities"}, class: 'list-group-item d-flex justify-content-between align-items-center' do
                plain "{{activity}}"
                span attributes: {"@click": "deleteActivity(index)"}, class: 'badge badge-primary badge-pill', text: 'X'
              end
            end
          end
        end
      end
    end
  end
```

Also update the response method in `app/matestack/components/person/disclaimer.rb` to have this content:

```ruby
  def response
    div id: 'disclaimer', class: 'container-fluid text-center', attributes: {"v-show": "show == true"} do
      span text: 'None of the presented names belong to and/or are meant to refer to existing human beings. They were created using a "Random Name Generator".'
      button class: 'btn btn-warning', attributes: {"@click": "show = false"}, text: 'Hide'
    end
  end
```

And add a `disclaimer.scss` file right next to it - this is where we will store specific styles that only apply to this custom component. Of course, this works for both static and dynamic custom components!

To test it, add the following content:

```css
#disclaimer {
  background-color: #767786;
  color: #E8E8EB;
  padding: 0.7rem 0;
  .btn {
    margin-left: 2rem;
    margin-bottom: 2px;
    @include media-breakpoint-down(md) {
      display: block;
      margin-top: 5px;
      margin-left: auto;
      margin-right: auto;
    }
  }
}
```

Now, the only thing left to do is importing the component at the bottom of `app/javascript/css/custom-bootstrap.scss`. By adding it below the line importing Bootstrap, we can make use of the neat helpers (like **md** in `@include media-breakpoint-down(md)`)!

The import statement looks like this:

```css
@import '../../matestack/components/person/disclaimer';
```

Again, let's add our changes to Git by running

```sh
git add . && git commit -m "Update custom components with (custom) styling"
```

## Adding a loading spinner

To make use of the Bootstrap loading spinner, we need to update our matestack demo app response method like so:

```ruby
  def response
    navigation
    div id: 'spinner', class: 'spinner-border', role: 'status' do
      span class: 'sr-only', text: 'Loading...'
    end
    main id: 'page-content' do
      person_disclaimer
      yield_page
    end
  end
```

Then, we need to add the functionality. Let's create a file in
`app/javascript/animations/loading-spinner.js` with the following content:

```js
MatestackUiCore.matestackEventHub.$on('page_loading', function(url){
  //hide old content
  document.querySelector('#page-content').style.opacity = 0;
  setTimeout(function () {
    //show loading spinner
    document.querySelector('#spinner').style.display = "inline-block";
  }, 150);
});

MatestackUiCore.matestackEventHub.$on('page_loaded', function(url){
  setTimeout(function () {
    //hide loading spinner
    document.querySelector('#spinner').style.display = "none";
    //show new content
    document.querySelector('#page-content').style.opacity = 1;
  }, 500);
});
```

This code switches between showing/hiding page content and loading spinner, based on events that get emitted by the page transitions - a topic we will cover in greater detail somewhere else.

To make the transition even smoother and position the spinning animation correctly, add a file in `app/javascript/css/loading-spinner.scss` and add those lines:

```css
#page-content{
  transition:opacity 0.2s linear;
}

#spinner {
  position: fixed;
  left: 47%;
  top: 20%;
  display: none;
}
```

Lastly, we need to import both the `js` and `css` file in `app/javascript/packs/application.js`:

```js
// ...
import 'css/application'
import 'css/loading-spinner'

// ...
import '../../matestack/components/person/activity'
import 'animations/loading-spinner'
```

Time to save the status quo by running
```sh
git add . && git commit -m "Add loading spinner to demo app"
```

## Recap & outlook

After following this guide, your application not only pleases the eye of a potential user, but more importantly you got an understanding of how to structure the styling of matestack pages and components.

Going ahead, the next part of this series covers [authentication via Devise](/docs/guides/2-essential/11_authentication_devise.md).


<hr id="bootstrap-asset-pipeline">

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
@import "person/disclaimer";
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
