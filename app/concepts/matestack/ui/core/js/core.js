import Vue from 'vue/dist/vue.esm'

// Import from app/concepts/matestack/ui/core:
import app from '../app/app'
import pageContent from '../page/content/content'
import store from '../app/store'
import component from '../component/component'
import anonymDynamicComponent from '../component/anonym-dynamic-component'
import collectionContent from '../collection/content/content'
import collectionFilter from '../collection/filter/filter'
import collectionOrder from '../collection/order/order'

// IMPORTS AT NEW LOCATION
// TODO: optimize js
import toggle from '../../../../../../lib/matestack/ui/vue_js/components/toggle'
import onclick from '../../../../../../lib/matestack/ui/vue_js/components/onclick'
import transition from '../../../../../../lib/matestack/ui/vue_js/components/transition'
import async from '../../../../../../lib/matestack/ui/vue_js/components/async'
import action from '../../../../../../lib/matestack/ui/vue_js/components/action'
import cable from '../../../../../../lib/matestack/ui/vue_js/components/cable'
import isolate from '../../../../../../lib/matestack/ui/vue_js/components/isolated'
import form from '../../../../../../lib/matestack/ui/vue_js/components/form/form'
import formCheckbox from '../../../../../../lib/matestack/ui/vue_js/components/form/checkbox'
import formInput from '../../../../../../lib/matestack/ui/vue_js/components/form/input'
import formRadio from '../../../../../../lib/matestack/ui/vue_js/components/form/radio'
import formSelect from '../../../../../../lib/matestack/ui/vue_js/components/form/select'
import formTextarea from '../../../../../../lib/matestack/ui/vue_js/components/form/textarea'
import formCheckboxMixin from '../../../../../../lib/matestack/ui/vue_js/components/form/checkbox_mixin'
import formInputMixin from '../../../../../../lib/matestack/ui/vue_js/components/form/input_mixin'
import formRadioMixin from '../../../../../../lib/matestack/ui/vue_js/components/form/radio_mixin'
import formSelectMixin from '../../../../../../lib/matestack/ui/vue_js/components/form/select_mixin'
import formTextareaMixin from '../../../../../../lib/matestack/ui/vue_js/components/form/textarea_mixin'

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
