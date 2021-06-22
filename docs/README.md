---
description: >-
  Matestack Ui Core - Boost your productivity & easily create component based
  web UIs in pure Ruby. Reactivity based on Vue.js included if desired. No Opal
  involved.
---

# Welcome

{% hint style="info" %}
Version 2.0.0 was released on the 12th of April and proudly presented at RailsConf. Click here for more [details](migrate-from-1.x-to-2.0.md)

**Most important changes:**

* Changed to MIT License
* 5 to 12 times better rendering performance \(depending on the context\)
* Removed Trailblazer dependency
* Improved core code readability/maintainability
{% endhint %}

## **What is Matestack?**

Matestack enables Rails developers to craft maintainable web UIs in pure Ruby, skipping ERB and HTML. UI code becomes a native and fun part of your Rails app. Thanks to reactive core components built on top of Vue.js, reactivity can be optionally added without writing JavaScript, just using a simple Ruby DSL.

If necessary, extend with pure JavaScript. **No Opal involved.**

{% hint style="success" %}
**Share feedback, get support and get involved!** Join our growing [community](community/discord.md), get to know the [core team](about/team.md) and learn how to [contribute ](community/contribute.md)in order to make Matestack better every day!
{% endhint %}

## Why Matestack?

Matestack presented and explained at RailsConf 2021:

{% embed url="https://www.youtube.com/watch?v=bwsVgCb97v0" %}

Matestack was created because modern web app development became more and more complex due to the rise of JavaScript frontend frameworks and the SPA frontend/REST API/JSON backend architecture. This sophisticated approach might be suitable for big teams and applications but is way to complex for most of small to medium sized teams and application scopes.

In contrast, Matestack helps Rails developers creating modern, reactive web apps while focusing on **simplicity**, **developer happiness** and **productivity**:

* [x] Use Ruby’s amazing language features while creating your UI
* [x] Skip using templating engine syntax and write pure Ruby instead
* [x] Reduce the amount of required JavaScript in order to build reactive web UIs
* [x] Create a single application, managing the full stack from database to a reactive UI in pure Ruby
* [x] **Drastically reduce the complexity of building reactive web applications** 

## What makes Matestack different?

[Hotwire](https://hotwire.dev) and [Stimulus Reflex](https://docs.stimulusreflex.com) are awesome gems. They reduce the amount of required JavaScript when implementing reactive web UIs. They allow us to use more Rails and less JavaScript. **Great!**

Matestack, developed since 2018, goes even one step further: **Use more Ruby and less of everything else** \(JavaScript, ERB/HAML/SLIM, CSS\).

{% hint style="info" %}
**Why?** Because Ruby is just beautiful! More Ruby = More developer happiness = Higher productivity
{% endhint %}

Additionally, most of Matestack does not require Action Cable or Redis, but can optionally use the power of these tools.

## Ecosystem

Matestack currently offers two open source Ruby gems**:**

* `matestack-ui-core` ships all you need to build reactive UIs in pure Ruby. You have to take care of styling and additional UI components yourself.
* `matestack-ui-bootstrap`ships all you need to build beautiful, reactive UIs in pure Ruby and smart CRUD components based on Bootstrap v5. Don't think about styling anymore and just create admin or application UIs faster than ever before! **--&gt;** [https://docs.matestack.io/matestack-ui-bootstrap/](https://docs.matestack.io/matestack-ui-bootstrap/)

## Live Demo

Based on `matestack-ui-core` and `matestack-ui-bootstrap` this reactive dummy app was created in pure Ruby without writing any JavaScript, ERB/HAML/SLIM and CSS: \([check it out](https://dummy.matestack.io) \| [source code](https://github.com/matestack/matestack-ui-bootstrap/tree/main/spec/dummy)\)

![https://dummy.matestack.io](.gitbook/assets/image%20%281%29.png)

## Compatibility

### Ruby/Rails

`matestack-ui-core` and `matestack-ui-bootstrap` are automatically tested against:

* Rails 6.1.1 + Ruby 3.0.0
* Rails 6.1.1 + Ruby 2.7.2
* Rails 6.0.3.4 + Ruby 2.6.6
* Rails 5.2.4.4 + Ruby 2.6.6

{% hint style="danger" %}
Rails versions below 5.2 are not supported.
{% endhint %}

### Vue.js

`matestack-ui-core` requires Vue.js and Vuex for its reactivity features. Following version ranges are supported:

* Vue.js ^2.6.0
* Vuex ^3.6.0

{% hint style="info" %}
Vue 3 / Vuex 4 update is planned for Q2 2021.
{% endhint %}

### Webpacker/Sprockets

`matestack-ui-core` is designed to be installed via Npm or Yarn and bundled via something like Webpacker together with all your other dependencies.

{% hint style="warning" %}
Since 2.0.0 we're not shipping a pre-bundled JavaScript assets for Rails assets pipeline \(Sprockets\) users anymore.
{% endhint %}

## Getting Started

Before you dive into some code, you should read about the basic architecture concepts and different ways to build with Matestack:

{% page-ref page="getting-started/concepts-rails-integration.md" %}

After that, it might be a good idea to boost your knowledge with our quick start guide:

{% page-ref page="getting-started/quick-start.md" %}

## Roadmap

Do you want to know what we're currently working on and what's planned for the next releases? Check out our GitHub Project board: [https://github.com/orgs/matestack/projects/1](https://github.com/orgs/matestack/projects/1)

