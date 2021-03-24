import Vue from 'vue/dist/vue.esm'
import matestackEventHub from '../event_hub'
import componentMixin from './mixin'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return { }
  },
  methods: {
    perform: function(){
      matestackEventHub.$emit(this.componentConfig["emit"], this.componentConfig["data"])
    }
  }
}

let component = Vue.component('matestack-ui-core-onclick', componentDef)

export default componentDef
