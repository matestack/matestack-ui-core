import Vue from 'vue/dist/vue.esm'

import app from 'app/js/app'
import store from 'app/js/store'
import component from 'component/js/component'
import anonymDynamicComponent from 'component/js/anonym-dynamic-component'
import html from 'html/js/html'
import transition from 'transition/js/transition'
import action from 'action/js/action'
import form from 'form/js/form'

let basemateUiApp = undefined

document.addEventListener('DOMContentLoaded', () => {

    basemateUiApp = new Vue({
      el: "#basemate_ui",
      store: store
    })

})

export default Vue
