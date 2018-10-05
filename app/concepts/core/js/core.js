import Vue from 'vue/dist/vue.esm'

import app from 'app/js/app'
import store from 'app/js/store'
import component from 'component/js/component'
import html from 'html/js/html'
import transition from 'transition/js/transition'



document.addEventListener('DOMContentLoaded', () => {

    const basemateUiApp = new Vue({
      el: "#basemate_ui",
      store: store
    })

})

export default Vue
