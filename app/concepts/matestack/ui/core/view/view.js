import Vue from 'vue/dist/vue.esm'

import matestackEventHub from 'js/event-hub'

import componentMixin from 'component/component'

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
    matestackEventHub.$on(this.componentConfig["show"], self.show)
    matestackEventHub.$on(this.componentConfig["hide"], self.hide)
    if(this.componentConfig["init"] == "show"){
      this.showing = true
    }
    if(this.componentConfig["init"] == "hide"){
      this.showing = false
    }
  },
  beforeDestroy: function() {
    const self = this
    matestackEventHub.$off(this.componentConfig["show"], self.show);
    matestackEventHub.$off(this.componentConfig["hide"], self.hide);
  },
}

let component = Vue.component('matestack-ui-core-view-cell', componentDef)

export default componentDef
