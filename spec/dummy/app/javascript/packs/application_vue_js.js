/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require("@rails/ujs").start()
require("channels")

import { createApp } from 'vue'
import MatestackUiVueJs from 'matestack-ui-vue_js'

//for specs only
window.MatestackUiVueJs = MatestackUiVueJs // making MatestackUiVueJs globally available for test compatability
// MatestackUiVueJs.Vue = Vue // test compatability
import registerCustomComponents from '../js/components' //for specs only
//for specs only

const appInstance = createApp({})

registerCustomComponents(appInstance) //for specs only

document.addEventListener('DOMContentLoaded', () => {
  MatestackUiVueJs.mount(appInstance)
})
