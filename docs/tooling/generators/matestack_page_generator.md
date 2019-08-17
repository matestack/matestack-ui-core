# Matestack Page Generator

## Usage

Generates matestack pages to `app/matestack/pages`.

## Parameters

**NAME** - Mandatory. Creates an empty matestack page in `app/matestack/pages/NAME.rb`.

**--app_name** - Mandatory. Adds a `/app_name` folder to `app/matestack/pages` to indicate to which matestack app the pages belongs. Pages _do not necessarily need to belong to an app_, but for now the page scaffolder can only provide this functionality.

**--namespace** - Optional. Adds a `/namespace` folder within the `/app_name` and a namespace to the `page.rb`. You can also scope the namespace using additional `/`'s like so: `namespace_1/namespace_2`

**--controller_action** - Optional. Takes a `controller#action` to use in the created route for the page. If not provided, a `controller#action` is created from **NAME** and **--app_name**.

## Example 1

```bash
rails generate matestack_page simple_page --app_name example_app
```

Creates a SimplePage in `app/matestack/pages/example_app/simple_page.rb`.

It also adds `get '#example_app/simple_page', to: 'example_app#simple_page'` to the `config/routes.rb` and proposes a
```ruby
def simple_page
  responder_for(Pages::ExampleApp::SimplePage)
end
```
in the terminal to use in your controller.

## Example 2

```bash
rails generate matestack_page second_page --app_name example_app --namespace sample_namespace
```

Creates a SimplePage in `app/matestack/pages/example_app/sample_namespace/second_page.rb`.

It also adds `get '#example_app/sample_namespace/second_page', to: 'example_app#second_page'` to the `config/routes.rb` and proposes a
```ruby
def simple_page
  responder_for(Pages::ExampleApp::SampleNamespace::SecondPage)
end
```
in the terminal to use in your, e.g., `example_app_controller.rb`.

To see all options, run
```bash
rails generate matestack_page -h
```
