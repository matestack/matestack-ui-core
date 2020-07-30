import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VRuntimeTemplate from "v-runtime-template"
import matestackEventHub from '../js/event-hub'

const componentDef = {
  props: ['componentConfig', 'params'],
  data: function(){
    return {
      isolatedTemplate: null,
      loading: false,
      loadingError: false
    }
  },
  methods: {
    renderIsolatedContent: function(){
      var self = this;
      self.loading = true;
      self.loadingError = false;
      axios({
        method: "get",
        url: location.pathname + location.search,
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        },
        params: {
          "component_class": self.componentConfig["component_class"],
          "public_options": self.componentConfig["public_options"]
        }
      })
      .then(function(response){
        self.loading = false;
        self.isolatedTemplate = response['data'];
      })
      .catch(function(error){
        self.loadingError = true;
        matestackEventHub.$emit('isolate_rerender_error', { class: self.componentConfig["component_class"] })
      })
    },
    startDefer: function(){
      const self = this
      self.loading = true;
      setTimeout(function () {
        self.renderIsolatedContent()
      }, parseInt(this.componentConfig["defer"]));
    }
  },
  created: function () {
    const self = this
  },
  beforeDestroy: function() {
    const self = this
    if(this.componentConfig["rerender_on"] != undefined){
      var rerender_events = this.componentConfig["rerender_on"].split(",")
      rerender_events.forEach(rerender_event => matestackEventHub.$off(rerender_event.trim(), self.renderIsolatedContent));
    }
  },
  mounted: function (){
    const self = this
    if(this.componentConfig["init_on"] === undefined){
      if(self.componentConfig["defer"] != undefined){
        if(!isNaN(self.componentConfig["defer"])){
          self.startDefer()
        }
      }else{
        self.renderIsolatedContent();
      }
    }else{
      if(self.componentConfig["defer"] != undefined){
        if(!isNaN(self.componentConfig["defer"])){
          var init_on_events = this.componentConfig["init_on"].split(",")
          init_on_events.forEach(init_on_event => matestackEventHub.$on(init_on_event.trim(), self.startDefer));
        }
      }else{
        var init_on_events = this.componentConfig["init_on"].split(",")
        init_on_events.forEach(init_on_event => matestackEventHub.$on(init_on_event.trim(), self.renderIsolatedContent));
      }
    }

    if(this.componentConfig["rerender_on"] != undefined){
      var rerender_events = this.componentConfig["rerender_on"].split(",")
      rerender_events.forEach(rerender_event => matestackEventHub.$on(rerender_event.trim(), self.renderIsolatedContent));
    }

  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('matestack-ui-core-isolate', componentDef)

export default componentDef
