import Vue from 'vue/dist/vue.esm'

import basemateEventHub from 'core/js/event-hub'

import componentMixin from 'component/js/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return { }
  },
  methods: {
    perform: function(){
      basemateEventHub.$emit(this.componentConfig["emit"], this.componentConfig["data"])
    }
  }
}

let component = Vue.component('onclick-cell', componentDef)

export default componentDef
