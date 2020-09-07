# Getting Started with Matestack

Demo: [Matestack Demo](https://demo.matestack.io)<br>
Github Repo: [Matestack Demo Application](https://github.com/matestack/matestack-demo-application)

## Guide Assumptions

This guide is designed for Ruby on Rails beginners, advanced and experienced developers. We assume that you have basic knowledge about how Ruby on Rails routing and action controllers work. In this series of guides we will cover the basic principles and usage of matestack and further down the road introduce more complex principles and example use cases.

## What is Matestack?

Matestack deeply integrates a Vue.js based UI into Ruby on Rails, offering prebuilt components. Use these prebuild components to write dynamic Web-UIs mostly in pure Ruby and with minimum effort. Matestack enables you to develop rich SPA like interfaces in no time and without touching javascript. And if you need to go deeper you can always create your own custom components to do so. 

## Concept

Matestack's UI concept consists of apps, pages and components. An app works like a layout in Rails, pages are the equivalent of views and components represent reusable UI elements.

### Apps

Views in Rails are usually wrapped in a layout. Often the Layout contains ui parts like navigation bars or footers which should be rendered around every view. With Matestack an app replaces the concept of the layout. Application wide ui parts like navigation bars or footers are defined inside an app. Pages can be rendered inside an app and the app will take care of transitioning between pages without reloading and rerendering the whole browser page. Thereby switching between pages feels more app like or SPA like and requires no additional coding on your side.

A web application can consist of multiple apps. For example an online shop can have a public app, which defines the navigation and footer for lets say a product index and show page and the cart etc. And the online shop has another administration app, which defines a navigation sidebar and manages all administration pages like index, edit and new pages for products.

### Pages

Matestack introduces pages which replace Rails views. So instead of for example an index and show page you would have an index and show page. Whatever you would do in views you can do in pages. Pages can be rendered standalone or wrapped by an app. Like described above, when pages are wrapped by an app it is possible to transition between pages without a reload of the browser page.

### Components

Components are UI elements. You can create components and use them in your apps, pages or other components. Use components to structure your view code and create reusable elements. For example a component can be a simple customized button or a more complex card containing a title, image and your custom button.

To enable you to write your apps, pages and components in Ruby, matestack provides a large set of prebuild components. These Components are divided into two groups. There are `Matestack::Ui::Component`'s and `Matestack::Ui::VueComponent`'s.

#### `Matestack::Ui::Component`'s

For nearly all existing HTML5 Tags there is a component in order to create a ui element with this tag. Visit the [components API documentation](/docs/api/2-components/) for more information about `Matestack::Ui::Component`'s.

#### `Matestack::Ui::VueJsComponent`'s

VueJsComponents are more complex components. These always have a Vue.js counterpart and enable easy development of dynamic ui elements which would usually require you to write javascript code. VueJsComponents provide an abstraction so you don't have to write javascript code and instead create rich interfaces in Ruby. Visit the [components API documentation](/docs/api/2-components/) for more information about `Matestack::Ui::VueJsComponent`'s.

## Recap & outlook

We introduced you to the apps, pages and components concepts of matestack. In order to unterstand better how matestack works, we create an application from the ground up using matestack and enhancing it step by step while leveraging more and more features of matestack.
Read the following guides to get started with matestack and get a better understanding about how apps, pages, components work.

Let's setup a rails app with matestack by following the [next guide](/docs/guides/2-essential/01_setup.md)
