import Vue from 'vue'
import axios from 'axios'
import VRuntimeTemplate from "vue3-runtime-template"
import matestackEventHub from '../event_hub'

const componentDef = {
  props: ['props', 'params'],
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
      if(self.props["rerender_delay"] != undefined){
        setTimeout(function () {
          self.renderIsolatedContent();
        }, parseInt(this.props["rerender_delay"]));
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
          "component_class": self.props["component_class"],
          "public_options": self.props["public_options"]
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
        matestackEventHub.$emit('isolate_rerender_error', { class: self.props["component_class"] })
      })
    },
    startDefer: function(){
      const self = this
      self.loading = true;
      setTimeout(function () {
        self.renderIsolatedContent()
      }, parseInt(this.props["defer"]));
    }
  },
  created: function () {
    const self = this
  },
  beforeDestroy: function() {
    const self = this
    if(this.props["rerender_on"] != undefined){
      var rerender_events = this.props["rerender_on"].split(",")
      rerender_events.forEach(rerender_event => matestackEventHub.$off(rerender_event.trim(), self.renderIsolatedContent));
    }
  },
  mounted: function (){
    const self = this
    if(this.props["init_on"] === undefined || this.props["init_on"] === null){
      if(self.props["defer"] == true || Number.isInteger(self.props["defer"])){
        if(!isNaN(self.props["defer"])){
          self.startDefer()
        }
        else{
          self.renderIsolatedContent();
        }
      }
    }else{
      if(self.props["defer"] != undefined){
        if(!isNaN(self.props["defer"])){
          var init_on_events = this.props["init_on"].split(",")
          init_on_events.forEach(init_on_event => matestackEventHub.$on(init_on_event.trim(), self.startDefer));
        }
      }else{
        var init_on_events = this.props["init_on"].split(",")
        init_on_events.forEach(init_on_event => matestackEventHub.$on(init_on_event.trim(), self.renderIsolatedContent));
      }
    }

    if(this.props["rerender_on"] != undefined){
      var rerender_events = this.props["rerender_on"].split(",")
      rerender_events.forEach(rerender_event => matestackEventHub.$on(rerender_event.trim(), self.rerender));
    }

  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('matestack-ui-core-isolate', componentDef)

export default componentDef
