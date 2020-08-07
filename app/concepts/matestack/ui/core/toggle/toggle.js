import Vue from 'vue/dist/vue.esm'
import matestackEventHub from '../js/event-hub'
import componentMixin from '../component/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {
      showing: true,
      hide_after_timeout: null,
      event: {
        data: {}
      }
    }
  },
  methods: {
    show: function(event_data){
      const self = this
      if (this.showing === true){
        return
      }
      this.showing = true
      this.event.data = event_data
      if(this.componentConfig["hide_after"] != undefined){
        self.hide_after_timeout = setTimeout(function () {
          self.hide()
        }, parseInt(this.componentConfig["hide_after"]));
      }
    },
    hide: function(){
      this.showing = false
      this.event.data = {}
    }
  },
  created: function () {
    const self = this
    if(this.componentConfig["show_on"] != undefined){
      this.showing = false
      var show_events = this.componentConfig["show_on"].split(",")
      show_events.forEach(show_event => matestackEventHub.$on(show_event.trim(), self.show));
    }
    if(this.componentConfig["hide_on"] != undefined){
      var hide_events = this.componentConfig["hide_on"].split(",")
      hide_events.forEach(hide_event => matestackEventHub.$on(hide_event.trim(), self.hide));
    }
    if(this.componentConfig["show_on"] != undefined){
      this.showing = false
    }
    if(this.componentConfig["init_show"] == true){
      this.showing = true
    }
  },
  beforeDestroy: function() {
    const self = this
    clearTimeout(self.hide_after_timeout)
    matestackEventHub.$off(this.componentConfig["show_on"], self.show);
    matestackEventHub.$off(this.componentConfig["hide_on"], self.hide);
    if(this.componentConfig["show_on"] != undefined){
      var shown_events = this.componentConfig["show_on"].split(",")
      shown_events.forEach(show_event => matestackEventHub.$off(show_event.trim(), self.show));
    }
    if(this.componentConfig["hide_on"] != undefined){
      var hiden_events = this.componentConfig["hide_on"].split(",")
      hiden_events.forEach(hide_event => matestackEventHub.$off(hide_event.trim(), self.hide));
    }
  },
}

let component = Vue.component('matestack-ui-core-toggle', componentDef)

export default componentDef
