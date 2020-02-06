import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

// Import from app/concepts/matestack/ui/core:
import matestackEventHub from '../../../app/concepts/matestack/ui/core/js/event-hub'
import componentMixin from '../../../app/concepts/matestack/ui/core/component/component'
import matestackUiCore from '../../../app/concepts/matestack/ui/core/js/core'

import styles from './styles/index.scss'

const MatestackUiCore = {
  Vue,
  Vuex,
  axios,
  matestackEventHub,
  componentMixin
}

window.MatestackUiCore = MatestackUiCore

export default MatestackUiCore