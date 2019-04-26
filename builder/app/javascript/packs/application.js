/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'
import matestackEventHub from 'core/js/event-hub'
import componentMixin from 'component/js/component'

import matestackUiCore from 'core/js/core'

export {
  Vue,
  Vuex,
  axios,
  matestackEventHub,
  componentMixin
}
