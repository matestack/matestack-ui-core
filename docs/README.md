---
description: >-
  Matestack Ui Core - Boost your productivity & easily create component based
  web UIs in pure Ruby. Reactivity based on Vue.js included if desired. No Opal
  involved.
---

# Welcome

### **What is Matestack?**

Matestack enables Rails developers to craft maintainable web UIs in pure Ruby, skipping ERB and HTML. UI code becomes a native and fun part of your Rails app. Thanks to reactive core components built on top of Vue.js, reactivity can be optionally added without writing JavaScript, just using a simple Ruby DSL.

If necessary, extend with pure JavaScript. **No Opal involved.**

{% hint style="success" %}
**Share feedback, get support and get involved!** Join our growing [community](community/discord.md), get to know the [core team](about/team.md) and learn how to [contribute ](community/contribute.md)in order to make Matestack better every day!
{% endhint %}

### Why Matestack?

Matestack was created because modern web app development became more and more complex due to the rise of JavaScript frontend frameworks and the SPA frontend/REST API/JSON backend architecture. This sophisticated approach might be suitable for big teams and applications but is way to complex for most of small to medium sized teams and application scopes. 

In contrast, Matestack helps Rails developers creating modern, reactive web apps while focusing on **simplicity**, **developer happiness** and **productivity**:

* [x] Use Ruby’s amazing language features while creating your UI
* [x] Skip using templating engine syntax and write pure Ruby instead
* [x] Reduce the amount of required JavaScript in order to build reactive web UIs
* [x] Create a single application, managing the full stack from database to a reactive UI in pure Ruby
* [x] **Drastically reduce the complexity of building reactive web applications** 

### What makes Matestack different?

[Hotwire](https://hotwire.dev) and [Stimulus Reflex](https://docs.stimulusreflex.com) are awesome gems. They reduce the amount of required JavaScript when implementing reactive web UIs. They allow us to use more Rails and less JavaScript. **Great!**

Matestack, developed since 2018, goes even one step further: **Use more Ruby and less of everything else** \(JavaScript, ERB/HAML/SLIM, CSS\).

{% hint style="info" %}
**Why?** Because Ruby is just beautiful! More Ruby = More developer happiness = Higher productivity
{% endhint %}

Additionally, most of Matestack does not require Action Cable or Redis, but can optionally use the power of these tools.

### Ecosystem

Matestack currently offers two open source Ruby gems**:**

* `matestack-ui-core` ships all you need to build reactive UIs in pure Ruby. You have to take care of styling and additional UI components yourself.
* `matestack-ui-bootstrap`ships all you need to build beautiful, reactive UIs in pure Ruby and smart CRUD components based on Bootstrap v5. Don't think about styling anymore and just create admin or application UIs faster than ever before! **\(specs and docs in progress currently\) --&gt;** [**https://matestack.gitbook.io/matestack-ui-bootstrap/**](https://matestack.gitbook.io/matestack-ui-bootstrap/)\*\*\*\*

### Live Demo

Based on `matestack-ui-core` and `matestack-ui-bootstrap` this reactive dummy app was created in pure Ruby without writing any JavaScript, ERB/HAML/SLIM and CSS: \([check it out](https://dummy.matestack.io) \| [source code](https://github.com/matestack/matestack-ui-bootstrap/tree/main/spec/dummy)\)

![https://dummy.matestack.io](.gitbook/assets/image%20%281%29.png)

### Compatibility

#### Ruby/Rails

`matestack-ui-core` and `matestack-ui-bootstrap` are automatically tested against:

* Rails 6.1.1 + Ruby 3.0.0
* Rails 6.1.1 + Ruby 2.7.2
* Rails 6.0.3.4 + Ruby 2.6.6
* Rails 5.2.4.4 + Ruby 2.6.6

{% hint style="danger" %}
Rails versions below 5.2 are not supported.
{% endhint %}

#### Vue.js

`matestack-ui-core` currently uses Vue.js 2.6.12 and Vuex 3.6.2 for its reactivity features. Custom reactive components are currently bound to these versions as well.

{% hint style="info" %}
Vue 3 / Vuex 4 update is planned for Q2 2021.
{% endhint %}

### Getting Started

Before you dive into some code, you should read about the basic architecture concepts and different ways to build with Matestack:

{% page-ref page="getting-started/concepts-rails-integration.md" %}

After that, it might be a good idea to boost your knowledge with our quick start guide:

{% page-ref page="getting-started/quick-start.md" %}

### Deep Dive

Craft your UI based on your components written in pure Ruby. Utilizing Ruby's amazing language features, you're able to create a cleaner and more maintainable UI implementation:

Learn more about UI components implemented in pure Ruby:

{% page-ref page="ui-components/component-overview.md" %}

What about going even one step further and implement **reactive** UIs in pure Ruby? Matestack's reactive core components can be used with a simple Ruby DSL enabling you to create reactive UIs without touching JavaScript!

Learn more about the optional reactivity system built on top of Vue.js and how you can use reactive core components in pure Ruby:

{% page-ref page="reactivity/reactivity-overview.md" %}

The last step in order to leverage the full Matestack power: Create app \(~Rails layout\) and page \(Rails ~view\) classes and implement dynamic page transitions without any JavaScript implementation required optionally enriched with some CSS animations.

Learn more about SPA-like Apps implemented in pure Ruby:

{% page-ref page="spa-like-apps/spa-overview.md" %}

