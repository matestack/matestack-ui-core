import Vue from 'vue/dist/vue.esm'

import app from 'app/js/app'
import async from 'async/js/async'
import pageContent from 'page/js/content'
import store from 'app/js/store'
import component from 'component/js/component'
import anonymDynamicComponent from 'component/js/anonym-dynamic-component'
import html from 'html/js/html'
import transition from 'transition/js/transition'
import action from 'action/js/action'
import form from 'form/js/form'
import view from 'view/js/view'
import onclick from 'onclick/js/onclick'

let basemateUiApp = undefined

document.addEventListener('DOMContentLoaded', () => {

    basemateUiApp = new Vue({
      el: "#basemate_ui",
      store: store
    })

})

export default Vue
