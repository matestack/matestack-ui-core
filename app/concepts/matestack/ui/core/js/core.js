import Vue from 'vue/dist/vue.esm'

// Import from app/concepts/matestack/ui/core:
import app from '../app/app'
import pageContent from '../page/content/content'
import store from '../app/store'
import component from '../component/component'
import anonymDynamicComponent from '../component/anonym-dynamic-component'
import form from '../form/form'
import formInput from '../form/input/input'
import formInputMixin from '../form/input/mixin'
import formSelect from '../form/select/select'
import formSelectMixin from '../form/select/mixin'
import formRadio from '../form/radio/radio'
import formRadioMixin from '../form/radio/mixin'
import formCheckbox from '../form/checkbox/checkbox'
import formCheckboxMixin from '../form/checkbox/mixin'
import formTextarea from '../form/textarea/textarea'
import formTextareaMixin from '../form/textarea/mixin'
import formSubmit from '../form/submit/submit'
import collectionContent from '../collection/content/content'
import collectionFilter from '../collection/filter/filter'
import collectionOrder from '../collection/order/order'
import isolate from '../isolated/isolated'

// IMPORTS AT NEW LOCATION
// TODO: optimize js
import toggle from '../../../../../../lib/matestack/ui/vue_js/components/toggle'
import onclick from '../../../../../../lib/matestack/ui/vue_js/components/onclick'
import transition from '../../../../../../lib/matestack/ui/vue_js/components/transition'
import async from '../../../../../../lib/matestack/ui/vue_js/components/async'
import action from '../../../../../../lib/matestack/ui/vue_js/components/action'
import cable from '../../../../../../lib/matestack/ui/vue_js/components/cable'

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
      store: store
  })
})

export default Vue
