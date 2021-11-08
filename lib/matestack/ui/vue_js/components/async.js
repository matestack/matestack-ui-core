import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VRuntimeTemplate from "v-runtime-template"
import matestackEventHub from '../event_hub'
import componentMixin from './mixin'

const componentDef = {
 mixins: [componentMixin],
 data: function(){
   return {
     asyncTemplate: null,
     showing: true,
     loading: false,
     hideAfterTimeout: null,
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
     if(this.props["defer"] != undefined){
       if(!isNaN(this.props["defer"])){
         this.startDefer()
       }
     }
     if(this.props["hide_after"] != undefined){
       self.hideAfterTimeout = setTimeout(function () {
         self.hide()
       }, parseInt(this.props["hide_after"]));
     }
   },
   hide: function(){
     this.showing = false
     this.event.data = {}
   },
   startDefer: function(){
     const self = this
     self.loading = true;
     setTimeout(function () {
       self.rerender()
     }, parseInt(this.props["defer"]));
   },
   rerender: function(){
     var self = this;
     self.loading = true;
     axios({
       method: "get",
       url: location.pathname + location.search,
       headers: {
         'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
       },
       params: {
         "component_key": self.props["component_key"],
         "component_class": self.props["parent_class"]
       }
     })
         .then(function(response){
           var tmp_dom_element = document.createElement('div');
           tmp_dom_element.innerHTML = response['data'];
           var template = tmp_dom_element.querySelector('#' + self.props["component_key"]).outerHTML;
           self.loading = false;
           self.asyncTemplate = template;
         })
         .catch(function(error){
           console.log(error)
           matestackEventHub.$emit('async_rerender_error', { id: self.props["component_key"] })
         })
   }
 },
 created: function () {
   const self = this
   self.registerEvents(this.props['show_on'], self.show)
   self.registerEvents(this.props['hide_on'], self.hide)
   self.registerEvents(this.props['rerender_on'], self.rerender)
   if(this.props["show_on"] != undefined){
     this.showing = false
   }
   if(this.props["defer"] != undefined){
     if(!isNaN(this.props["defer"])){
       if (this.props["show_on"] == undefined){
         this.startDefer()
       }
     }
   }
   if(this.props["init_show"] == true){
     console.log("(inside the if init show = true - it's showing !!!!!")
     this.showing = true
   }
 },
 beforeDestroy: function() {
   const self = this
   clearTimeout(self.hideAfterTimeout)
   puts("%%%%% hi ")
   self.removeEvents(this.props["show_on"], self.show)
   self.removeEvents(this.props["hide_on"], self.hide)
   self.removeEvents(this.props["rerender_on"], self.rerender)
 },
 components: {
   VRuntimeTemplate: VRuntimeTemplate
 }
}

let component = Vue.component('matestack-ui-core-async', componentDef)

export default componentDef

