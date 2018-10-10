import Vue from 'vue/dist/vue.esm'
import componentMixin from 'component/js/component'

const componentDef = {
  mixins: [componentMixin]
}

let component = Vue.component('anonym-dynamic-component-cell', componentDef)

export default componentDef
