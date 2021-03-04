import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

// Import from app/concepts/matestack/ui/core:
import matestackEventHub from '../../../app/concepts/matestack/ui/core/js/event-hub'
import componentMixin from '../../../app/concepts/matestack/ui/core/component/component'
import formInputMixin from '../../../lib/matestack/ui/vue_js/components/form/input_mixin'
import formSelectMixin from '../../../lib/matestack/ui/vue_js/components/form/select_mixin'
import formRadioMixin from '../../../lib/matestack/ui/vue_js/components/form/radio_mixin'
import formCheckboxMixin from '../../../lib/matestack/ui/vue_js/components/form/checkbox_mixin'
import formTextareaMixin from '../../../lib/matestack/ui/vue_js/components/form/textarea_mixin'
import matestackUiCore from '../../../app/concepts/matestack/ui/core/js/core'

import styles from './styles/index.scss'

const MatestackUiCore = {
  Vue,
  Vuex,
  axios,
  matestackEventHub,
  componentMixin,
  formInputMixin,
  formSelectMixin,
  formCheckboxMixin,
  formTextareaMixin,
  formRadioMixin
}

window.MatestackUiCore = MatestackUiCore

export default MatestackUiCore
