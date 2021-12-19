// import Vue from 'vue'
// import Vuex from 'vuex'
// import axios from 'axios'

import eventHub from './event_hub'

const matestackEventHub = eventHub // for compatibility with 1.x

import componentMixin from './components/mixin'

import app from './app/app'
import store from './app/store'

import pageContent from './page/content' //TODO Rename to page

import collectionContent from './components/collection/content'
import collectionFilter from './components/collection/filter'
import collectionOrder from './components/collection/order'

import toggle from './components/toggle'
import onclick from './components/onclick'
import transition from './components/transition'
import async from './components/async'
import action from './components/action'
import cable from './components/cable'
import isolate from './components/isolated'
import form from './components/form/form'
import formCheckbox from './components/form/checkbox'
import formInput from './components/form/input'
import formRadio from './components/form/radio'
import formSelect from './components/form/select'
import formTextarea from './components/form/textarea'

import formInputMixin from './components/form/input_mixin'
import formSelectMixin from './components/form/select_mixin'
import formRadioMixin from './components/form/radio_mixin'
import formCheckboxMixin from './components/form/checkbox_mixin'
import formTextareaMixin from './components/form/textarea_mixin'

const MatestackUiCore = {
  store,
  eventHub,
  matestackEventHub, // for compatibility with 1.x
  componentMixin,
  formInputMixin,
  formSelectMixin,
  formCheckboxMixin,
  formTextareaMixin,
  formRadioMixin
}

export default MatestackUiCore
