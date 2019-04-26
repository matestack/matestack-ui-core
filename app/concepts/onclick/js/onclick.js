import Vue from 'vue/dist/vue.esm'

import matestackEventHub from 'core/js/event-hub'

import componentMixin from 'component/js/component'

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

let component = Vue.component('onclick-cell', componentDef)

export default componentDef
