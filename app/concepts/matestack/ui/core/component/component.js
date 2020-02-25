import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VRuntimeTemplate from "v-runtime-template"
import matestackEventHub from '../js/event-hub'

const componentMixin = {
  props: ['componentConfig', 'params'],
  data: function(){
    return {
      asyncTemplate: null
    }
  },
  methods: {
    onMatestackUiCoreChannel: function(event){
      if (this.componentConfig["rerender_on"] == event.message){
        this.rerender()
      }
    },
    rerender: function(){
      var self = this;
      self.params["component_key"] = self.componentConfig["component_key"]
      axios({
        method: "get",
        url: location.pathname + location.search,
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        },
        params: {"component_key": self.componentConfig["component_key"]}
      })
      .then(function(response){
        self.asyncTemplate = response["data"];
      })
    },
    rerenderWith: function(newParams){
      Object.assign(this.params, newParams);
      this.rerender()
    }
  },
  created: function () {
    const self = this
    matestackEventHub.$on('MatestackUiCoreChannel', self.onMatestackUiCoreChannel)
  },
  beforeDestroy: function() {
    const self = this
    matestackEventHub.$off('MatestackUiCoreChannel', self.onMatestackUiCoreChannel)
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

export default componentMixin
