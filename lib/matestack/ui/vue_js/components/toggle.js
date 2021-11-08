import Vue from 'vue/dist/vue.esm'
import matestackEventHub from '../event_hub'
import componentMixin from './mixin'

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
       console.log("showing === true")
       return
     }
     this.showing = true
     this.event.data = event_data
     if(this.props["hide_after"] != undefined){
       self.hide_after_timeout = setTimeout(function () {
         console.log("*****")
         self.hide()
       }, parseInt(this.props["hide_after"]));
     }
   },
   hide: function(){
     console.log(this)
     console.log('hide function')
     this.showing = false
     this.event.data = {}
   }
 },
 created: function () {
   const self = this
   if(this.props["show_on"] != undefined){
     console.log("show_on")
     this.showing = false
     var show_events = this.props["show_on"].split(",")
     show_events.forEach(show_event => matestackEventHub.$on(show_event.trim(), self.show));
   }
   if(this.props["hide_on"] != undefined){
     console.log("hide_on")
     var hide_events = this.props["hide_on"].split(",")
     hide_events.forEach(hide_event => matestackEventHub.$on(hide_event.trim(), self.hide));
   }
   if(this.props["hide_after"] != undefined){
     console.log("hide_after")
     this.showing = false
   }
   if(this.props["init_show"] == true){
     console.log("init_show")
     this.showing = true
   }
 },
 beforeDestroy: function() {
   const self = this
   clearTimeout(self.hide_after_timeout)
   matestackEventHub.$off(this.props["show_on"], self.show);
   matestackEventHub.$off(this.props["hide_on"], self.hide);
   if(this.props["show_on"] != undefined){
     var shown_events = this.props["show_on"].split(",")
     shown_events.forEach(show_event => matestackEventHub.$off(show_event.trim(), self.show));
   }
   if(this.props["hide_on"] != undefined){
     var hiden_events = this.props["hide_on"].split(",")
     hiden_events.forEach(hide_event => matestackEventHub.$off(hide_event.trim(), self.hide));
   }
 },
}

let component = Vue.component('matestack-ui-core-toggle', componentDef)

export default componentDef
