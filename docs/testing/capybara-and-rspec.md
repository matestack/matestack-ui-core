# Capybara & Rspec \[WIP\]

Matestack apps, pages and components can be tested with various test setups. We're using Rspec and Capybara a lot when creating apps with Matestack or work on Matestack's core itself and want to show you some basic elements of this setup.

We will show you how to setup a **headless chrome** for testing, because a headless browser approach gives you performance benefits and is better suited to be integrated in a CI/CD pipeline.

## Setup

In this guide we assume that you know the basics of Rspec and Capybara and have both gems installed. If not, please read the basics about these tools here:

* [https://github.com/rspec/rspec-rails](https://github.com/rspec/rspec-rails)
* [https://github.com/teamcapybara/capybara](https://github.com/teamcapybara/capybara)

Additionally you need a Chrome browser installed on your system. 

We recommend to configure Capybara in a separate file and require it in your `rails_helper.rb`

{% tabs %}
{% tab title="spec/rails\_helper.rb" %}
```ruby
# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Dir[File.join File.dirname(__FILE__), "support", "**", "*.rb"].each { |f| require f }
# Add additional requires below this line. Rails is not loaded until this point!
```
{% endtab %}

{% tab title="spec/support/capybara.rb" %}
```ruby
require "capybara/rspec"
require "capybara/rails"
require "selenium/webdriver"

# port used for debugging (explained later)
Capybara.server_port = 33123
Capybara.server_host = "0.0.0.0"

Capybara.register_driver :headless_chrome do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new.tap do |o|
    o.add_argument "--headless"
    o.add_argument "--no-sandbox"
    o.add_argument "--disable-dev-shm-usage"
    o.add_argument "--disable-gpu"
    o.add_argument "--enable-features=NetworkService,NetworkServiceInProcess"
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
end
Capybara.default_driver = :headless_chrome

```
{% endtab %}
{% endtabs %}

## Writing basic specs

Imagine having implemented a Matestack page like:

{% tabs %}
{% tab title="app/matestack/some\_page.rb" %}
```ruby
class SomePage < Matestack::Ui::Page

  def response
    plain "hello world!"
  end
  
end
```
{% endtab %}

{% tab title="app/controllers/some\_controller.rb" %}
```ruby
class SomeController < ApplicationController
  
  include Matestack::Ui::Core::Helper
  
  def some_page
    render SomePage
  end
  
end
```
{% endtab %}

{% tab title="config/routes.rb" %}
```ruby
Rails.application.routes.draw do 

  get 'some_page', to: 'some#some_page'
  
end
```
{% endtab %}
{% endtabs %}

A spec might look like this:

{% tabs %}
{% tab title="spec/features/hello\_world\_spec.rb" %}
```ruby
require "rails_helper"

describe "Some Page", type: :feature do
  
  it "should render hello world" do
    visit some_page_path
    expect(page).to have_content("hello world!")
  end

end

```
{% endtab %}
{% endtabs %}

and then run this spec with `bundle exec rspec spec/features/hello_world_spec.rb`

This should start a webserver and trigger the headless chrome to request the specified page from it. Just like Capybara is working.

## Testing asynchronous features

{% hint style="info" %}
Above, we just tested a static "hello world" rendering and didn't use any JavaScript based functionality. We need to activate the JavaScript driver in specs where Matestack's built-in \(or your own\) JavaScript is required. 
{% endhint %}

Let's add some basic built-in reactivity of Matestack, which requires JavaScript to work:

```ruby
class SomePage < Matestack::Ui::Page

  def response
    onclick emit: "show_hello" do
      button "click me"
    end
    async show_on: "show_hello", id: "hello" do
      plain "hello world!"
    end
  end
  
end
```

The spec could look like this: **Note that you now have to add the `js: true` on line 3!**

{% tabs %}
{% tab title="spec/features/hello\_world\_spec.rb" %}
```ruby
require "rails_helper"

describe "Some Page", type: :feature, js: true do
  
  it "should render hello world after clicking on a button" do
    visit some_page_path
    expect(page).not_to have_content("hello world!")
    click "click me"
    expect(page).to have_content("hello world!")
  end

end
```
{% endtab %}
{% endtabs %}

Capybara by default will wait for 2000ms before failing on an expectation. `expect(page).to have_content("hello world!")` therefore may take up to 2000ms to become truthy without breaking the spec. Following the documentation of Capybara, you can adjust the default wait time or set it individually on specific expectations. This built-in wait mechanism is especially useful when working with features requiring client-server communication, like page transitions, form or action submissions!

## Testing forms and actions

Imagine a  `matestack_form` used for creating new `User` ActiveRecord Model instances:

```ruby
class SomePage < Matestack::Ui::Page

  def response
    matestack_form form_config do
      form_input key: :name, type: :text, label: "Name"
      button "submit me", type: :submit
    end
    toggle show_on: "succeeded" do
      plain "succeeded!"
    end
    toggle show_on: "failed" do
      plain "failed!"
    end
  end
  
  def form_config
    {
      for: User.new,
      path: users_path,
      method: :post,
      success: { emit: "succeeded" },
      failure: { emit: "failed" }
    }
  end
  
end
```

The according spec might look like this:

{% tabs %}
{% tab title="spec/features/form\_submission\_spec.rb" %}
```ruby
require "rails_helper"

describe "Some Page", type: :feature, js: true do
  
  it "should render hello world" do
    visit some_page_path
    fill_in "Name", with: "Foo"
    click "submit me"
    
    expect(page).to have_content("succeeded!")
  end

end
```
{% endtab %}
{% endtabs %}

If you want to test if the User model was correctly saved in the Database, you could do something like this:

{% tabs %}
{% tab title="spec/features/form\_submission\_spec.rb" %}
```ruby
describe "Some Page", type: :feature, js: true do
  
  it "should render hello world" do
    visit some_page_path
    fill_in "Name", with: "Foo"
    
    expect {
      click "submit me"
      expect(page).to have_content("succeeded!") #required to work properly!
    }.to change { User.count }.by(1)
    
    # from here on, we know for sure that the form was submitted
    expect(User.last.name).to eq "Foo"
  end

end
```
{% endtab %}
{% endtabs %}

{% hint style="danger" %}
**Beware of the timing trap!**

Without adding `expect(page).to have_content("succeeded!")` after `click "submit me"` the spec would fail. The `User.count` would be executed too early! You  somehow need to use Capybara's built-in wait mechanisim in order to identify a successful asynchronous form submission. Otherwise the spec would just click the submit button and immediately expect a database state change. Unlike Capybara, plain Rspec expectations do not wait a certain amount of time before failing! Gems like [https://github.com/laserlemon/rspec-wait](https://github.com/laserlemon/rspec-wait) are trying to address this issue. In our experience, you're better of using Capybara's built-in wait mechanism like shown in the example, though. 
{% endhint %}

 Above described approaches and hints apply for actions as well!

## Optional: Dockerized test setup \[WIP\]

