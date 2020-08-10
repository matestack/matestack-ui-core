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
    rerender: function(){
      var self = this;
      self.loading = true;
      self.loadingError = false;
      if(self.componentConfig["rerender_delay"] != undefined){
        setTimeout(function () {
          self.renderIsolatedContent();
        }, parseInt(this.componentConfig["rerender_delay"]));
      } else {
        self.renderIsolatedContent();
      }
    },
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
        self.loadingStart = false;
        self.loadingEnd = true;
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
    console.log('mounted isolated component')
    if(this.componentConfig["init_on"] === undefined || this.componentConfig["init_on"] === null){
      console.log('Its me')
      if(self.componentConfig["defer"] == true || Number.isInteger(self.componentConfig["defer"])){
        console.log('I should render deferred')
        if(!isNaN(self.componentConfig["defer"])){
          self.startDefer()
        }
        else{
          self.renderIsolatedContent();
        }
      }
      else {
        console.log('I should NOT render deferred')
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
      rerender_events.forEach(rerender_event => matestackEventHub.$on(rerender_event.trim(), self.rerender));
    }

  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('matestack-ui-core-isolate', componentDef)

export default componentDef
