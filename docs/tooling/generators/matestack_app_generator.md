# Matestack App Generator

## Usage

Generates matestack apps to `app/matestack/apps`.

## Parameters

**NAME** - Mandatory. Creates an empty matestack page in `app/matestack/apps/NAME.rb`.

**--all_inclusive** - Optional. Also creates a corresponding matestack page, a controller with an action for the matestack page and a route to it.

## Example 1

```bash
rails generate matestack:app example_app
```

Creates an ExampleApp in `app/matestack/apps/example_app.rb`.

## Example 2

```bash
rails generate matestack:app simple_app --all_inclusive
```

Creates:
- a SimpleApp in `app/matestack/apps/simple_app.rb`
- an ExamplePage in `app/matestack/pages/simple_app/example_page.rb`
- a SimpleAppController in `app/controllers/simple_app_controller.rb`
- a route to `http://localhost:3000/simple_app/example_page`

To see all options, run
```bash
rails generate matestack:app -h
```
