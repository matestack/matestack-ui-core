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
      //self.params["component_key"] = self.componentConfig["component_key"]
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
        self.asyncTemplate = template;
      })
      .catch(function(error){
        console.log(error)
        matestackEventHub.$emit('async_rerender_error', { id: self.componentConfig["component_key"] })
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
