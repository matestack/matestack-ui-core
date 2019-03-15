import Vue from 'vue/dist/vue.esm'

import basemateEventHub from 'core/js/event-hub'

import componentMixin from 'component/js/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {
      showing: false
    }
  },
  methods: {
    show: function(){
      this.showing = true
    },
    hide: function(){
      this.showing = false
    }
  },
  created: function () {
    const self = this
    basemateEventHub.$on(this.componentConfig["show"], self.show)
    basemateEventHub.$on(this.componentConfig["hide"], self.hide)
    if(this.componentConfig["init"] == "show"){
      this.showing = true
    }
    if(this.componentConfig["init"] == "hide"){
      this.showing = false
    }
  },
  beforeDestroy: function() {
    const self = this
    basemateEventHub.$off(this.componentConfig["show"], self.show);
    basemateEventHub.$off(this.componentConfig["hide"], self.hide);
  },
}

let component = Vue.component('view-cell', componentDef)

export default componentDef
