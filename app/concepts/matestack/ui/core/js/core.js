import Vue from 'vue/dist/vue.esm'

import app from 'app/app'
import async from 'async/async'
import pageContent from 'page/content'
import store from 'app/store'
import component from 'component/component'
import anonymDynamicComponent from 'component/anonym-dynamic-component'
import html from 'html/html'
import transition from 'transition/transition'
import action from 'action/action'
import form from 'form/form'
import view from 'view/view'
import onclick from 'onclick/onclick'
import collectionContent from 'collection/content/content'
import collectionFilter from 'collection/filter/filter'
import collectionOrder from 'collection/order/order'

let matestackUiApp = undefined

document.addEventListener('DOMContentLoaded', () => {

    matestackUiApp = new Vue({
      el: "#matestack_ui",
      store: store
    })

})

export default Vue
