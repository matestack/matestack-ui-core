import Vue from 'vue/dist/vue.esm'
import componentMixin from 'component/js/component'

const componentDef = {
  mixins: [componentMixin]
}

let component = Vue.component('partial-cell', componentDef)

export default component
