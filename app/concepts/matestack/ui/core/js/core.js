import Vue from 'vue/dist/vue.esm'
import { turbolinksAdapterMixin } from 'vue-turbolinks';

// Import from app/concepts/matestack/ui/core:
import app from '../app/app'
import async from '../async/async'
import pageContent from '../page/content/content'
import toggle from '../toggle/toggle'
import store from '../app/store'
import component from '../component/component'
import anonymDynamicComponent from '../component/anonym-dynamic-component'
import transition from '../transition/transition'
import action from '../action/action'
import form from '../form/form'
import onclick from '../onclick/onclick'
import collectionContent from '../collection/content/content'
import collectionFilter from '../collection/filter/filter'
import collectionOrder from '../collection/order/order'
import isolate from '../isolated/isolated'

let matestackUiApp = undefined

// this event fires first and always
document.addEventListener('DOMContentLoaded', () => {
  // somehow we need to inject the turbolinks mixin even
  // if the turbolinks:load event will recreate the vue instance
  // skipping the injection here caused errors when submitting forms or action
  // if they were present on the first page, which was loaded and activated turbolinks
  // the mixin does not impact the app when turbolinks is disabled
  matestackUiApp = new Vue({
      el: "#matestack-ui",
      mixins: [turbolinksAdapterMixin],
      store: store
  })
})

// this event fires after DOMContentLoaded and only if turbolinks are enabled
document.addEventListener('turbolinks:load', () => {
  // we need to empty the currently stored pageTemplate state variable
  // otherwise the matestack page will jump back to the latest pageTemplate
  // fetched during the last matestack transition as the turbolinks powered
  // page transition does not write the matestack store pageTemplate state variable
  store.commit('resetPageTemplate')
  // we need to destroy the vue app instance
  matestackUiApp.$destroy();
  // and recreate it right afterwards in order to work when used with turbolinks
  matestackUiApp = new Vue({
      el: "#matestack-ui",
      mixins: [turbolinksAdapterMixin],
      store: store
  })
})

export default Vue
