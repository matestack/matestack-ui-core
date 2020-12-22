import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

// Import from app/concepts/matestack/ui/core:
import matestackEventHub from '../../../app/concepts/matestack/ui/core/js/event-hub'
import componentMixin from '../../../app/concepts/matestack/ui/core/component/component'
import formInputMixin from '../../../app/concepts/matestack/ui/core/form/input/mixin'
import formSelectMixin from '../../../app/concepts/matestack/ui/core/form/select/mixin'
import formRadioMixin from '../../../app/concepts/matestack/ui/core/form/radio/mixin'
import formCheckboxMixin from '../../../app/concepts/matestack/ui/core/form/checkbox/mixin'
import formTextareaMixin from '../../../app/concepts/matestack/ui/core/form/textarea/mixin'
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
