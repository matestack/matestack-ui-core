import Vue from 'vue/dist/vue.esm'
import componentMixin from './component'

const componentDef = {
  mixins: [componentMixin]
}

let component = Vue.component('matestack-ui-core-anonym-dynamic-component', componentDef)

export default componentDef
