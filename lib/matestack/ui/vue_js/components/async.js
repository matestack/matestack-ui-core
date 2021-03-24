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
      if(this.componentConfig["defer"] != undefined){
        if(!isNaN(this.componentConfig["defer"])){
          this.startDefer()
        }
      }
      if(this.componentConfig["hide_after"] != undefined){
        self.hideAfterTimeout = setTimeout(function () {
          self.hide()
        }, parseInt(this.componentConfig["hide_after"]));
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
      }, parseInt(this.componentConfig["defer"]));
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
          "component_key": self.componentConfig["component_key"],
          "component_class": self.componentConfig["parent_class"]
        }
      })
      .then(function(response){
        var tmp_dom_element = document.createElement('div');
        tmp_dom_element.innerHTML = response['data'];
        var template = tmp_dom_element.querySelector('#' + self.componentConfig["component_key"]).outerHTML;
        self.loading = false;
        self.asyncTemplate = template;
      })
      .catch(function(error){
        console.log(error)
        matestackEventHub.$emit('async_rerender_error', { id: self.componentConfig["component_key"] })
      })
    }
  },
  created: function () {
    const self = this
    self.registerEvents(this.componentConfig['show_on'], self.show)
    self.registerEvents(this.componentConfig['hide_on'], self.hide)
    self.registerEvents(this.componentConfig['rerender_on'], self.rerender)
    if(this.componentConfig["show_on"] != undefined){
      this.showing = false
    }
    if(this.componentConfig["defer"] != undefined){
      if(!isNaN(this.componentConfig["defer"])){
        if (this.componentConfig["show_on"] == undefined){
          this.startDefer()
        }
      }
    }
    if(this.componentConfig["init_show"] == true){
      this.showing = true
    }
  },
  beforeDestroy: function() {
    const self = this
    clearTimeout(self.hideAfterTimeout)
    self.removeEvents(this.componentConfig["show_on"], self.show)
    self.removeEvents(this.componentConfig["hide_on"], self.hide)
    self.removeEvents(this.componentConfig["rerender_on"], self.rerender)
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('matestack-ui-core-async', componentDef)

export default componentDef
