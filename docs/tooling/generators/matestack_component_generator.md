# Matestack Component Generator

## Usage

Generates matestack components to `app/matestack/components`.

## Parameters

**NAME** - Mandatory. Creates an empty matestack component in `app/matestack/components/NAME.rb`.

**--dynamic** - Optional. Makes the created component dynamic and also creates a corresponding `app/matestack/components/NAME.js` file.

**--haml** - Optional. Creates a `app/matestack/components/NAME.haml` file to use 'normal' HTML tags.

**--scss** - Optional. Creates an `app/matestack/components/NAME.scss` for custom component styling.

## Example

```bash
rails generate matestack:component simple_component
```

Creates a SimpleComponent in `app/matestack/components/simple_component.rb`.

To see all options, run
```bash
rails generate matestack:component -h
```
